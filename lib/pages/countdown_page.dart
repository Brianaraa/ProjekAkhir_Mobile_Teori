import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/countdown_service.dart';
import '../services/notification_service.dart';
import '../models/countdown_model.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  final CountdownService _service = CountdownService();
  final NotificationService _notificationService = NotificationService();

  List<CountdownModel> _data = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getMyCountdowns();

      setState(() {
        _data = result;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching countdown: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data countdown';
        _isLoading = false;
        _data = [];
      });
    }
  }

  void _showAddDialog() {
    final judulController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Countdown Baru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: judulController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Hajatan/Kegiatan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      DateFormat('dd MMMM yyyy').format(selectedDate),
                    ),
                    subtitle: const Text('Klik untuk pilih tanggal'),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (judulController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama hajatan tidak boleh kosong')),
                          );
                          return;
                        }

                        try {
                          await _service.addCountdown(
                            judulController.text.trim(),
                            selectedDate,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            fetchData(); // Refresh list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Countdown berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Simpan Countdown'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Fungsi untuk kirim notifikasi testing
  Future<void> _sendTestNotification(CountdownModel item) async {
  final notifId = item.uuid.hashCode.abs();

  try {
    print('🔄 Mencoba kirim notifikasi ID: $notifId');

    await _notificationService.showNow(
      id: notifId,
      title: 'Testing Notifikasi Hajatan',
      body: 'H-${item.sisaHari.abs()} • ${item.judul}',
    );

    print('showNow dipanggil tanpa error');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi dikirim ke sistem')),
      );
    }
  } catch (e) {
    print('gagal mmengirim notifikasi: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 70, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada countdown', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(
              'Tekan tombol + untuk menambahkan',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        final tanggalFormat = DateFormat('dd MMM yyyy').format(item.tanggal);
        final isPast = item.sisaHari < 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item.judul,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal: $tanggalFormat'),
                const SizedBox(height: 4),
                Text(
                  item.sisaHariLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isPast ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_active, color: Color(0xFFd4af37)),
                  tooltip: 'Kirim notifikasi sekarang',
                  onPressed: () => _sendTestNotification(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}