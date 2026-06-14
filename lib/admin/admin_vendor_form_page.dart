import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_akhir/models/vendor_admin_model.dart';
import 'package:projek_akhir/services/admin_vendor_service.dart';

class AdminVendorFormPage extends StatefulWidget {
  final VendorAdminModel? vendor; // null = tambah baru

  const AdminVendorFormPage({super.key, this.vendor});

  @override
  State<AdminVendorFormPage> createState() => _AdminVendorFormPageState();
}

class _AdminVendorFormPageState extends State<AdminVendorFormPage> {
  final _service = AdminVendorService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaCtrl;
  late final TextEditingController _deskripsiCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _sosmedCtrl;
  late final TextEditingController _telponeCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  bool _isActive = true;
  bool _isSaving = false;
  Uint8List? _photoBytes;
  String? _photoName;

  bool get _isEdit => widget.vendor != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vendor;
    _namaCtrl     = TextEditingController(text: v?.namaVendor ?? '');
    _deskripsiCtrl = TextEditingController(text: v?.deskripsi ?? '');
    _alamatCtrl   = TextEditingController(text: v?.alamat ?? '');
    _sosmedCtrl   = TextEditingController(text: v?.sosmed ?? '');
    _telponeCtrl  = TextEditingController(text: v?.telpone ?? '');
    _latCtrl      = TextEditingController(
        text: v?.latitude.toString() ?? '');
    _lngCtrl      = TextEditingController(
        text: v?.longitude.toString() ?? '');
    _isActive     = v?.isActive ?? true;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF2C1810),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFFd4af37)),
              title: const Text('Kamera',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo,
                  color: Color(0xFFd4af37)),
              title: const Text('Galeri',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 1200);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoName  = file.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final vendor = VendorAdminModel(
      uuid: widget.vendor?.uuid ?? '',
      namaVendor: _namaCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      sosmed: _sosmedCtrl.text.trim(),
      telpone: _telponeCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text.trim()) ?? 0,
      longitude: double.tryParse(_lngCtrl.text.trim()) ?? 0,
      isActive: _isActive,
    );

    String? vendorId;
    bool success = false;

    if (_isEdit) {
      success = await _service.updateVendor(widget.vendor!.uuid, vendor);
      vendorId = widget.vendor!.uuid;
    } else {
      vendorId = await _service.createVendor(vendor);
      success = vendorId != null;
    }

    // Upload foto jika ada
    if (success && vendorId != null && _photoBytes != null) {
      await _service.uploadVendorMainPhoto(vendorId, _photoBytes!);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Vendor berhasil diperbarui'
              : 'Vendor berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan vendor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1008),
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Vendor' : 'Tambah Vendor'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Color(0xFFd4af37), strokeWidth: 2))
                : const Text('Simpan',
                    style: TextStyle(
                        color: Color(0xFFd4af37),
                        fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto utama vendor
              _sectionTitle('Foto Utama Vendor'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C1810),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFd4af37).withOpacity(0.3),
                        style: BorderStyle.solid),
                    image: _photoBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_photoBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _photoBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate,
                                color: Color(0xFFd4af37), size: 40),
                            const SizedBox(height: 8),
                            Text('Tap untuk upload foto utama vendor',
                                style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.5),
                                    fontSize: 13)),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _photoBytes = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Informasi Vendor'),
              const SizedBox(height: 12),

              _formField(
                controller: _namaCtrl,
                label: 'Nama Vendor',
                hint: 'Contoh: Catering Nusantara',
                icon: Icons.store,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              _formField(
                controller: _deskripsiCtrl,
                label: 'Deskripsi / Kategori',
                hint: 'Contoh: Katering, Dekorasi, Fotografer...',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              _formField(
                controller: _alamatCtrl,
                label: 'Alamat Lengkap',
                hint: 'Jl. Contoh No. 1, Yogyakarta',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              _formField(
                controller: _telponeCtrl,
                label: 'Nomor Telepon',
                hint: '0812xxxxxxxx',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              _formField(
                controller: _sosmedCtrl,
                label: 'Instagram / Website',
                hint: '@namavendor atau https://...',
                icon: Icons.link,
              ),

              const SizedBox(height: 24),
              _sectionTitle('Koordinat Lokasi (untuk Peta)'),
              const SizedBox(height: 6),
              Text(
                'Buka Google Maps → tap lokasi → salin koordinat',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _formField(
                      controller: _latCtrl,
                      label: 'Latitude',
                      hint: '-7.7956',
                      icon: Icons.south,
                      keyboard:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib';
                        if (double.tryParse(v) == null) return 'Angka';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _formField(
                      controller: _lngCtrl,
                      label: 'Longitude',
                      hint: '110.3695',
                      icon: Icons.east,
                      keyboard:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib';
                        if (double.tryParse(v) == null) return 'Angka';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Toggle aktif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status Vendor',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(
                          _isActive
                              ? 'Aktif — tampil di aplikasi user'
                              : 'Nonaktif — tersembunyi dari user',
                          style: TextStyle(
                              color: _isActive
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      activeColor: const Color(0xFFd4af37),
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            color: Color(0xFFd4af37),
            fontSize: 14,
            fontWeight: FontWeight.bold),
      );

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFFd4af37), fontSize: 13),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon:
            Icon(icon, color: const Color(0xFFd4af37), size: 20),
        filled: true,
        fillColor: const Color(0xFF2C1810),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFd4af37).withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd4af37)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _alamatCtrl.dispose();
    _sosmedCtrl.dispose();
    _telponeCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }
}
