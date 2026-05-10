import 'package:flutter/material.dart';
import 'package:projek_akhir/models/layanan_model.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/pages/payment_page.dart';
import 'package:projek_akhir/services/booking_service.dart';

class BookingFormPage extends StatefulWidget {
  final VendorModel vendor;
  final List<LayananModel> layananList;

  const BookingFormPage({
    super.key,
    required this.vendor,
    required this.layananList,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  DateTime? _selectedDate;
  LayananModel? _selectedLayanan;
  final TextEditingController _namaAcaraController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.layananList.isNotEmpty) {
      _selectedLayanan = widget.layananList.first;
    }
  }

  double get _totalPrice {
    return _selectedLayanan?.harga ?? 0;
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

  Future<void> _proceedToPayment() async {
    if (_selectedDate == null ||
        _selectedLayanan == null ||
        _namaAcaraController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal dan layanan terlebih dahulu'),
        ),
      );
      return;
    }

    try {
      final bookingId = await BookingService().createBooking(
        vendorId: widget.vendor.uuid,
        layananId: _selectedLayanan!.uuid,
        namaVendor: widget.vendor.namaVendor,
        namaLayanan: _selectedLayanan!.namaLayanan,
        namaAcara: _namaAcaraController.text.trim(),
        tanggalAcara: _selectedDate!,
        totalHarga: _totalPrice,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentPage(
            bookingId: bookingId,
            vendorId: widget.vendor.uuid,
            namaVendor: widget.vendor.namaVendor,
            layananId: _selectedLayanan!.uuid,
            namaAcara: _namaAcaraController.text.trim(),
            namaLayanan: _selectedLayanan!.namaLayanan,
            tanggalAcara: _selectedDate!,
            totalHarga: _totalPrice,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat booking: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF884513)),
        title: const Text(
          'Form Sewa Vendor',
          style: TextStyle(
            color: Color(0xFF884513),
            fontWeight: FontWeight.bold,
          ),
        ),
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
                border: Border.all(
                  color: const Color(0xFFd4af37).withOpacity(0.3),
                ),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFd4af37),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vendor.namaVendor,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.vendor.alamat,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Nama Acara',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _namaAcaraController,
              decoration: InputDecoration(
                hintText: 'Contoh: Ulang Tahun',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tanggal Acara
            const Text(
              'Tanggal Acara',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

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
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),

                    const Icon(Icons.calendar_month, color: Color(0xFF884513)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pilih Layanan
            const Text(
              'Pilih Layanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<LayananModel>(
                  value: _selectedLayanan,
                  isExpanded: true,
                  dropdownColor: const Color(0xfffcf9f8),

                  items: widget.layananList.map((layanan) {
                    return DropdownMenuItem<LayananModel>(
                      value: layanan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            layanan.namaLayanan,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          Text(
                            layanan.hargaFormatted,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLayanan = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Harga Estimasi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga Layanan',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    Text(_selectedLayanan?.hargaFormatted ?? '-'),
                  ],
                ),

                const Divider(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Harga',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${_totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFd4af37),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),

        child: SafeArea(
          child: ElevatedButton(
            onPressed: _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF884513),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            child: const Text(
              'Lanjut Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
