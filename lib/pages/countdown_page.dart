import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek_akhir/services/countdown_service.dart';
import 'package:projek_akhir/services/notification_service.dart';
import 'package:projek_akhir/models/countdown_model.dart';

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
      setState(() {
        _errorMessage = 'Gagal memuat data countdown';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTestNotification(CountdownModel item) async {
    final notifId = item.uuid.hashCode.abs();

    try {
      await _notificationService.showNow(
        id: notifId,
        title: 'Pengingat Hajatan',
        body: 'H-${item.sisaHari.abs()} • ${item.judul}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi dikirim')),
        );
      }
    } catch (e) {
      print('Error kirim notif: $e');
    }
  }

  Future<void> _deleteCountdown(CountdownModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xfffcf9f8),

        title: const Text(
          'Hapus Countdown',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF884513),
          ),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah kamu yakin ingin menghapus data ini?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              item.judul,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFd4af37),
              ),
            ),
          ],
        ),

        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteCountdown(item.uuid);
        fetchData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus')),
        );
      }
    }
  }

  void _showDialog({CountdownModel? item}) {
    final judulController =
        TextEditingController(text: item?.judul ?? '');
    DateTime selectedDate = item?.tanggal ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xfffcf9f8),
              title: Text(
                item == null ? 'Tambah Countdown' : 'Edit Countdown',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF884513)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: judulController,
                      decoration: InputDecoration(
                        labelText: 'Nama Hajatan',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        DateFormat('dd MMMM yyyy').format(selectedDate),
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (judulController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Judul tidak boleh kosong')),
                      );
                      return;
                    }

                    try {
                      if (item == null) {
                        await _service.addCountdown(
                          judulController.text.trim(),
                          selectedDate,
                        );
                      } else {
                        await _service.updateCountdown(
                          item.uuid,
                          judulController.text.trim(),
                          selectedDate,
                        );
                      }

                      Navigator.pop(context);
                      fetchData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(item == null
                              ? 'Berhasil ditambahkan'
                              : 'Berhasil diupdate'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af37),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    item == null ? 'Simpan' : 'Update',
                    style: const TextStyle(
                        color: Color(0xFF884513),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFd4af37)),
      );
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_data.isEmpty) {
      return const Center(child: Text('Belum ada countdown'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        final isPast = item.sisaHari < 0;
        final hari = item.sisaHari.abs();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFd4af37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$hari',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF884513),
                      ),
                    ),
                    const Text(
                      'hari',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  item.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.notifications_active,
                    color: Color(0xFFd4af37)),
                onPressed: () => _sendTestNotification(item),
              ),

              PopupMenuButton<String>(
                color: const Color(0xfffcf9f8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                onSelected: (value) {
                  if (value == 'edit') {
                    _showDialog(item: item);
                  } else if (value == 'delete') {
                    _deleteCountdown(item);
                  }
                },

                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit, size: 18, color: Color(0xFFd4af37)),
                        SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF884513),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, size: 18, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF884513), // icon titik 3 warna tema
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        title: const Text(
          'Countdown Saya',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF884513)),
        ),
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        color: const Color(0xFFd4af37),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFd4af37),
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add, color: Color(0xFF884513)),
      ),
    );
  }
}