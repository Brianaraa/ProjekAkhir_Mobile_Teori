import 'package:flutter/material.dart';
import 'package:projek_akhir/models/vendor_admin_model.dart';
import 'package:projek_akhir/services/admin_vendor_service.dart';
import 'package:projek_akhir/admin/admin_vendor_form_page.dart';
import 'package:projek_akhir/admin/admin_vendor_detail_page.dart';

class AdminVendorListPage extends StatefulWidget {
  const AdminVendorListPage({super.key});

  @override
  State<AdminVendorListPage> createState() => _AdminVendorListPageState();
}

class _AdminVendorListPageState extends State<AdminVendorListPage> {
  final _service = AdminVendorService();
  List<VendorAdminModel> _vendors = [];
  List<VendorAdminModel> _filtered = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _service.getAllVendors();
    if (mounted) {
      setState(() {
        _vendors  = data;
        _filtered = data;
        _isLoading = false;
      });
    }
  }

  void _search(String q) {
    setState(() {
      _query    = q.toLowerCase();
      _filtered = _vendors
          .where((v) =>
              v.namaVendor.toLowerCase().contains(_query) ||
              v.alamat.toLowerCase().contains(_query))
          .toList();
    });
  }

  Future<void> _toggleActive(VendorAdminModel v) async {
    await _service.toggleVendorActive(v.uuid, !v.isActive);
    _load();
  }

  Future<void> _confirmDelete(VendorAdminModel v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text('Hapus Vendor',
            style: TextStyle(color: Colors.white)),
        content: Text('Hapus "${v.namaVendor}" beserta semua layanannya?',
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
      await _service.deleteVendor(v.uuid);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1008),
      appBar: AppBar(
        title: const Text('Manajemen Vendor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminVendorFormPage()),
          );
          if (result == true) _load();
        },
        backgroundColor: const Color(0xFFd4af37),
        foregroundColor: const Color(0xFF1C1008),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Vendor',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama vendor atau alamat...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFFd4af37)),
                filled: true,
                fillColor: const Color(0xFF2C1810),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFd4af37)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Count label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${_filtered.length} vendor',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFd4af37)))
                : _filtered.isEmpty
                    ? Center(
                        child: Text('Vendor tidak ditemukan',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4))))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: const Color(0xFFd4af37),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) =>
                              _vendorCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _vendorCard(VendorAdminModel v) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminVendorDetailPage(vendorId: v.uuid),
          ),
        );
        if (result == true) _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C1810),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: v.isActive
                ? const Color(0xFFd4af37).withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: v.isActive
                    ? const Color(0xFFd4af37).withOpacity(0.15)
                    : Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  v.namaVendor.isNotEmpty
                      ? v.namaVendor[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: v.isActive
                        ? const Color(0xFFd4af37)
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.namaVendor,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(v.alamat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (v.ratingAvg != null) ...[
                        const Icon(Icons.star,
                            color: Colors.amber, size: 13),
                        Text(
                          ' ${v.ratingAvg!.toStringAsFixed(1)} (${v.ratingCount ?? 0})',
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: v.isActive
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v.isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            color: v.isActive ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              color: const Color(0xFF2C1810),
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              onSelected: (val) async {
                if (val == 'edit') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminVendorFormPage(vendor: v),
                    ),
                  );
                  if (result == true) _load();
                } else if (val == 'toggle') {
                  _toggleActive(v);
                } else if (val == 'delete') {
                  _confirmDelete(v);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit, color: Color(0xFFd4af37), size: 18),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(children: [
                    Icon(
                      v.isActive ? Icons.visibility_off : Icons.visibility,
                      color: v.isActive ? Colors.orange : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(v.isActive ? 'Nonaktifkan' : 'Aktifkan',
                        style: const TextStyle(color: Colors.white)),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
