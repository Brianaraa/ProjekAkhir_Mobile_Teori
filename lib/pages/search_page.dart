import 'package:flutter/material.dart';
import 'dart:async';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/services/notification_service.dart';
import 'package:projek_akhir/pages/vendor_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final _notifService = NotificationService();

  List<VendorModel> _allVendors = [];
  List<VendorModel> _filtered = [];
  bool _isLoading = true;
  String _query = '';
  Timer? _debounce;

  // Filter chip yang aktif
  String _activeFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Katering', 'Dekorasi', 'Fotografer', 'Gedung'];

  @override
  void initState() {
    super.initState();
    _loadVendors();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadVendors() async {
    try {
      final response = await _supabase.from('vendor').select();
      final vendors = (response as List)
          .map((e) => VendorModel.fromJson(e))
          .toList();
      setState(() {
        _allVendors = vendors;
        _filtered = vendors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat vendor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _query = _searchController.text.toLowerCase();
          _applyFilter();
        });
      }
    });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _allVendors.where((v) {
        final matchSearch = _query.isEmpty ||
            v.namaVendor.toLowerCase().contains(_query) ||
            v.alamat.toLowerCase().contains(_query) ||
            v.deksripsi.toLowerCase().contains(_query);

        // Filter kategori — cocokkan dengan field deskripsi vendor
        // (asumsi deskripsi mengandung kata kategori)
        final matchFilter = _activeFilter == 'Semua' ||
            v.deksripsi.toLowerCase().contains(_activeFilter.toLowerCase());

        return matchSearch && matchFilter;
      }).toList();
    });
  }

  void _setFilter(String filter) {
    setState(() => _activeFilter = filter);
    _applyFilter();
  }

  // Kirim notifikasi saat vendor disimpan/dipilih
  Future<void> _saveVendor(VendorModel vendor) async {
    await _notifService.showNow(
      id: vendor.id.hashCode,
      title: 'Vendor Disimpan ✓',
      body: '${vendor.namaVendor} telah ditambahkan ke daftar hajatanmu.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${vendor.namaVendor} disimpan ke hajatan'),
          backgroundColor: const Color(0xFF884513),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
        appBar: AppBar(
          backgroundColor:  const Color(0xfffcf9f8),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cari Vendor',
                    style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filtered.length} vendor ditemukan',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _searchBar(),
            ),

            const SizedBox(height: 12),

            // ── FILTER CHIPS ──
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filters.length,
                itemBuilder: (context, i) => _filterChip(_filters[i]),
              ),
            ),

            const SizedBox(height: 16),

            // ── LIST HASIL ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFd4af37)),
                    )
                  : _filtered.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) =>
                              _vendorCard(_filtered[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari nama vendor, alamat...',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _query.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _query = '');
                  _applyFilter();
                },
                child: const Icon(Icons.close, color: Colors.grey),
              )
            : null,
        filled: true,
        fillColor: const Color(0xfff6f3f2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFd4af37), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => _setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFd4af37) : const Color(0xfff6f3f2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFd4af37) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF884513) : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _vendorCard(VendorModel vendor) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VendorDetailPage(vendor: vendor)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Avatar initial
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  vendor.namaVendor.isNotEmpty
                      ? vendor.namaVendor[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFd4af37),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info vendor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.namaVendor,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vendor.alamat,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.deksripsi,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Tombol simpan
            GestureDetector(
              onTap: () => _saveVendor(vendor),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFd4af37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bookmark_add_outlined,
                  color: Color(0xFFd4af37),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _query.isEmpty ? 'Belum ada vendor' : 'Vendor "$_query" tidak ditemukan',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}