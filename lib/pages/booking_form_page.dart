import 'package:flutter/material.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/pages/payment_page.dart';

class BookingFormPage extends StatefulWidget {
  final VendorModel vendor;

  const BookingFormPage({super.key, required this.vendor});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  DateTime? _selectedDate;
  String _selectedAdat = 'Adat Jawa';
  
  final List<String> _adatList = [
    'Adat Jawa',
    'Adat Sunda',
    'Adat Minang',
    'Adat Batak',
    'Adat Bali',
    'Modern/Nasional'
  ];

  // Simulasi Harga Dasar
  final double _basePrice = 5000000.0;

  double get _totalPrice {
    double multiplier = 1.0;
    if (_selectedAdat == 'Adat Minang' || _selectedAdat == 'Adat Batak') {
      multiplier = 1.5; // Agak mahal
    } else if (_selectedAdat == 'Modern/Nasional') {
      multiplier = 0.8; // Lebih murah
    }
    return _basePrice * multiplier;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _proceedToPayment() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal acara terlebih dahulu')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          vendor: widget.vendor,
          tanggalAcara: _selectedDate!,
          jenisAdat: _selectedAdat,
          totalHarga: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF884513)),
        title: const Text('Form Sewa Vendor',
            style: TextStyle(color: Color(0xFF884513), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFd4af37).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFd4af37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.vendor.namaVendor[0].toUpperCase(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFd4af37)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.vendor.namaVendor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.vendor.alamat, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tanggal Acara
            const Text('Tanggal Acara', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Pilih tanggal hajatan'
                          : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                      style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black),
                    ),
                    const Icon(Icons.calendar_month, color: Color(0xFF884513)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Jenis Adat
            const Text('Jenis Acara / Adat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAdat,
                  isExpanded: true,
                  items: _adatList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAdat = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Harga Estimasi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF884513).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Harga Sewa', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Rp ${_totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFd4af37)),
                  ),
                ],
              ),
            ),
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
            onPressed: _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF884513),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Lanjut Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
