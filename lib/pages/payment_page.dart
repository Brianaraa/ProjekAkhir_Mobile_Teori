import 'package:flutter/material.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/models/booking_model.dart';
import 'package:projek_akhir/services/booking_local_service.dart';
import 'package:projek_akhir/services/currency_service.dart';
import 'package:projek_akhir/models/currency_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PaymentPage extends StatefulWidget {
  final VendorModel vendor;
  final DateTime tanggalAcara;
  final String jenisAdat;
  final double totalHarga;

  const PaymentPage({
    super.key,
    required this.vendor,
    required this.tanggalAcara,
    required this.jenisAdat,
    required this.totalHarga,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _currencyService = CurrencyService();
  final _bookingService = BookingLocalService();
  
  List<CurrencyModel> _rates = [];
  bool _isLoadingRates = true;

  int _selectedMethodIndex = 0;
  final List<Map<String, dynamic>> _methods = [
    {'name': 'QRIS', 'icon': Icons.qr_code_2, 'color': Colors.red},
    {'name': 'Mastercard', 'icon': Icons.credit_card, 'color': Colors.blue},
    {'name': 'Transfer Bank', 'icon': Icons.account_balance, 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    try {
      final rates = await _currencyService.getRates();
      if (mounted) {
        setState(() {
          _rates = rates;
          _isLoadingRates = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRates = false);
      }
    }
  }

  double _getConvertedPrice(String code) {
    if (_rates.isEmpty) return 0;
    final model = _rates.firstWhere((r) => r.code == code, orElse: () => _rates.first);
    return widget.totalHarga * model.rate;
  }

  Future<void> _processPayment() async {
    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFd4af37))),
    );

    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 2));

    // Save to SQLite
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'unknown_user';

    final booking = BookingModel(
      id: const Uuid().v4(),
      userId: userId,
      vendorId: widget.vendor.uuid,
      namaVendor: widget.vendor.namaVendor,
      tanggalAcara: widget.tanggalAcara,
      jenisAdat: widget.jenisAdat,
      totalHarga: widget.totalHarga,
      statusBayar: 'LUNAS - ${_methods[_selectedMethodIndex]['name']}',
      createdAt: DateTime.now(),
    );

    await _bookingService.saveBooking(booking);

    // Close Loading Dialog
    if (mounted) Navigator.pop(context);

    // Show Success & Pop
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          content: const Text(
            'Pembayaran Berhasil!\nVendor berhasil disewa.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // pop payment page
                  Navigator.pop(context); // pop booking form
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF884513)),
                child: const Text('Kembali ke Vendor', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usdPrice = _getConvertedPrice('USD');
    final eurPrice = _getConvertedPrice('EUR');

    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF884513)),
        title: const Text('Pembayaran', style: TextStyle(color: Color(0xFF884513), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${widget.totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF884513)),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  
                  if (_isLoadingRates)
                    const CircularProgressIndicator(strokeWidth: 2)
                  else if (_rates.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Dalam USD', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('\$${usdPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Dalam EUR', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('€${eurPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Payment Methods
            const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(_methods.length, (index) {
              final m = _methods[index];
              final isSelected = _selectedMethodIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedMethodIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFd4af37).withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? const Color(0xFFd4af37) : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(m['icon'], color: m['color']),
                      const SizedBox(width: 16),
                      Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFd4af37)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd4af37),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
