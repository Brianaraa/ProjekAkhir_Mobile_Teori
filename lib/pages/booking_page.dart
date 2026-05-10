import 'package:flutter/material.dart';
import 'package:projek_akhir/models/booking_model.dart';
import 'package:projek_akhir/pages/payment_page.dart';
import 'package:projek_akhir/services/booking_service.dart';
import 'package:projek_akhir/services/notification_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _service = BookingService();

  final NotificationService _notificationService = NotificationService();

  List<BookingModel> _data = [];

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
      final result = await _service.getMyBookings();

      result.sort((a, b) => a.tanggalAcara.compareTo(b.tanggalAcara));

      setState(() {
        _data = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat booking';

        _isLoading = false;
      });
    }
  }

  int _getRemainingDays(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  Future<void> _sendTestNotification(BookingModel item) async {
    final notifId = item.uuid.hashCode.abs();

    try {
      await _notificationService.showNow(
        id: notifId,
        title: 'Pengingat Hajatan',
        body:
            'H-${_getRemainingDays(item.tanggalAcara).abs()} • ${item.namaAcara}',
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notifikasi dikirim')));
      }
    } catch (e) {
      debugPrint('Error kirim notif: $e');
    }
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
      return const Center(child: Text('Belum ada booking acara'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];

        final hari = _getRemainingDays(item.tanggalAcara).abs();

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
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaAcara,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.namaVendor,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item.namaLayanan,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const SizedBox(height: 2),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: item.statusBayar == 'paid'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.statusBayar.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.statusBayar == 'paid'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // notif
              IconButton(
                icon: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFFd4af37),
                ),
                onPressed: () => _sendTestNotification(item),
              ),

              // bayar
              if (item.statusBayar == 'unpaid')
                IconButton(
                  icon: const Icon(Icons.payment, color: Colors.orange),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          bookingId: item.uuid,

                          vendorId: item.vendorId,

                          namaVendor: item.namaVendor,

                          layananId: item.layananId,

                          namaLayanan: item.namaLayanan,

                          namaAcara: item.namaAcara,

                          tanggalAcara: item.tanggalAcara,

                          totalHarga: item.totalHarga,
                        ),
                      ),
                    ).then((_) => fetchData());
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        title: const Text(
          'Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF352010),
          ),
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
    );
  }
}
