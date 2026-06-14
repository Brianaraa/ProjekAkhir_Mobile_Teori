import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_akhir/models/vendor_admin_model.dart';
import 'package:projek_akhir/models/layanan_admin_model.dart';
import 'package:projek_akhir/services/admin_vendor_service.dart';
import 'package:projek_akhir/admin/admin_vendor_form_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVendorDetailPage extends StatefulWidget {
  final String vendorId;
  const AdminVendorDetailPage({super.key, required this.vendorId});

  @override
  State<AdminVendorDetailPage> createState() => _AdminVendorDetailPageState();
}

class _AdminVendorDetailPageState extends State<AdminVendorDetailPage> {
  final _service = AdminVendorService();
  VendorAdminModel? _vendor;
  List<LayananAdminModel> _layanan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final v = await _service.getVendorById(widget.vendorId);
    final l = await _service.getLayananByVendor(widget.vendorId);
    if (mounted) {
      setState(() {
        _vendor = v;
        _layanan = l;
        _isLoading = false;
      });
    }
  }

  String _getMainImageUrl() {
    return Supabase.instance.client.storage
        .from('vendor')
        .getPublicUrl('${widget.vendorId}/main_picture.jpg');
  }

  // ─────────────────────────────────────────────
  // LAYANAN ACTIONS
  // ─────────────────────────────────────────────

  void _showLayananForm({LayananAdminModel? existing}) {
    final namaCtrl  = TextEditingController(text: existing?.namaLayanan ?? '');
    final descCtrl  = TextEditingController(text: existing?.deskripsi ?? '');
    final hargaCtrl = TextEditingController(
        text: existing?.harga?.toStringAsFixed(0) ?? '');
    Uint8List? photoBytes;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2C1810),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    existing == null ? 'Tambah Layanan' : 'Edit Layanan',
                    style: const TextStyle(
                        color: Color(0xFFd4af37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Foto layanan
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (file == null) return;
                      final bytes = await file.readAsBytes();
                      setSheet(() => photoBytes = bytes);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1008),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFd4af37).withOpacity(0.3)),
                        image: photoBytes != null
                            ? DecorationImage(
                                image: MemoryImage(photoBytes!),
                                fit: BoxFit.cover)
                            : (existing?.foto != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      Supabase.instance.client.storage
                                          .from('vendor')
                                          .getPublicUrl(
                                              '${widget.vendorId}/${existing!.foto}'),
                                    ),
                                    fit: BoxFit.cover,
                                    onError: (_, __) {})
                                : null),
                      ),
                      child: (photoBytes == null && existing?.foto == null)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate,
                                    color: Color(0xFFd4af37), size: 30),
                                const SizedBox(height: 6),
                                Text('Upload foto layanan (opsional)',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.4),
                                        fontSize: 12)),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _sheetField(namaCtrl, 'Nama Layanan',
                      'Contoh: Paket Silver 100 Pax', Icons.room_service),
                  const SizedBox(height: 12),
                  _sheetField(descCtrl, 'Deskripsi', 'Jelaskan isi paket...',
                      Icons.description_outlined,
                      maxLines: 3),
                  const SizedBox(height: 12),
                  _sheetField(hargaCtrl, 'Harga (IDR)', '500000',
                      Icons.attach_money,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setSheet(() => isSaving = true);
                              final layanan = LayananAdminModel(
                                uuid: existing?.uuid ?? '',
                                idVendor: widget.vendorId,
                                namaLayanan: namaCtrl.text.trim(),
                                deskripsi: descCtrl.text.trim().isEmpty
                                    ? null
                                    : descCtrl.text.trim(),
                                harga: double.tryParse(
                                    hargaCtrl.text.replaceAll('.', '')),
                                foto: existing?.foto,
                              );

                              String? savedId;
                              if (existing == null) {
                                savedId =
                                    await _service.createLayanan(layanan);
                              } else {
                                final ok = await _service.updateLayanan(
                                    existing.uuid, layanan);
                                if (ok) savedId = existing.uuid;
                              }

                              // Upload foto jika ada
                              if (savedId != null && photoBytes != null) {
                                final ext = 'layanan_$savedId.jpg';
                                await _service.uploadLayananPhoto(
                                    widget.vendorId, ext, photoBytes!);
                                // Update field foto
                                await _service.updateLayanan(
                                  savedId,
                                  LayananAdminModel(
                                    uuid: savedId,
                                    idVendor: widget.vendorId,
                                    namaLayanan: layanan.namaLayanan,
                                    deskripsi: layanan.deskripsi,
                                    harga: layanan.harga,
                                    foto: ext,
                                  ),
                                );
                              }

                              setSheet(() => isSaving = false);
                              if (ctx.mounted) Navigator.pop(ctx);
                              _load();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd4af37),
                        foregroundColor: const Color(0xFF1C1008),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Color(0xFF1C1008), strokeWidth: 2)
                          : Text(
                              existing == null
                                  ? 'Tambah Layanan'
                                  : 'Simpan Perubahan',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _deleteLayanan(LayananAdminModel l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text('Hapus Layanan',
            style: TextStyle(color: Colors.white)),
        content: Text('Hapus layanan "${l.namaLayanan}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFFd4af37))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.deleteLayanan(l.uuid);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1008),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFFd4af37))),
      );
    }

    final v = _vendor;
    if (v == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1C1008),
        appBar: AppBar(title: const Text('Detail Vendor')),
        body: const Center(
            child: Text('Vendor tidak ditemukan',
                style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1C1008),
      body: CustomScrollView(
        slivers: [
          // App bar dengan foto vendor
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1C1008),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminVendorFormPage(vendor: v),
                    ),
                  );
                  if (result == true) _load();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _getMainImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF2C1810),
                      child: const Icon(Icons.store,
                          color: Color(0xFFd4af37), size: 60),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.namaVendor,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: v.isActive
                                    ? Colors.green.withOpacity(0.8)
                                    : Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                v.isActive ? 'Aktif' : 'Nonaktif',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (v.ratingAvg != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              Text(
                                ' ${v.ratingAvg!.toStringAsFixed(1)} (${v.ratingCount ?? 0})',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards
                  _infoRow(Icons.location_on_outlined, 'Alamat', v.alamat),
                  if (v.telpone.isNotEmpty)
                    _infoRow(Icons.phone_outlined, 'Telepon', v.telpone),
                  if (v.sosmed.isNotEmpty)
                    _infoRow(Icons.link, 'Sosial Media', v.sosmed),
                  _infoRow(Icons.my_location, 'Koordinat',
                      '${v.latitude}, ${v.longitude}'),

                  const SizedBox(height: 28),

                  // Layanan section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Layanan (${_layanan.length})',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _showLayananForm(),
                        icon: const Icon(Icons.add,
                            color: Color(0xFFd4af37), size: 18),
                        label: const Text('Tambah',
                            style: TextStyle(
                                color: Color(0xFFd4af37),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_layanan.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1810),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFd4af37).withOpacity(0.2),
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.room_service_outlined,
                              color: Color(0xFFd4af37), size: 40),
                          const SizedBox(height: 12),
                          Text('Belum ada layanan',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5))),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showLayananForm(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFd4af37),
                              foregroundColor: const Color(0xFF1C1008),
                            ),
                            child: const Text('+ Tambah Layanan Pertama',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._layanan.map((l) => _layananCard(l)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1810),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFd4af37), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _layananCard(LayananAdminModel l) {
    final fotoUrl = l.foto != null
        ? Supabase.instance.client.storage
            .from('vendor')
            .getPublicUrl('${widget.vendorId}/${l.foto}')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1810),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFd4af37).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Foto
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: fotoUrl != null
                ? Image.network(fotoUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _layananPlaceholder())
                : _layananPlaceholder(),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.namaLayanan,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                if (l.deskripsi != null && l.deskripsi!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(l.deskripsi!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                  ),
                const SizedBox(height: 6),
                Text(
                  l.hargaFormatted,
                  style: const TextStyle(
                      color: Color(0xFFd4af37),
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
          ),

          // Menu
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit,
                    color: Color(0xFFd4af37), size: 20),
                onPressed: () => _showLayananForm(existing: l),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () => _deleteLayanan(l),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _layananPlaceholder() => Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1008),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.room_service,
            color: Color(0xFFd4af37), size: 30),
      );

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            const TextStyle(color: Color(0xFFd4af37), fontSize: 13),
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon:
            Icon(icon, color: const Color(0xFFd4af37), size: 20),
        filled: true,
        fillColor: const Color(0xFF1C1008),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFd4af37).withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd4af37)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
