import 'package:flutter/material.dart';
import 'dart:async';
import 'package:projek_akhir/models/vendor_models.dart';
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

  List<VendorModel> _allVendors = [];
  List<VendorModel> _filtered = [];
  bool _isLoading = true;
  String _query = '';
  Timer? _debounce;

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
          _applySearch();
        });
      }
    });
  }

  void _applySearch() {
    setState(() {
      _filtered = _allVendors.where((v) {
        return _query.isEmpty ||
            v.namaVendor.toLowerCase().contains(_query) ||
            v.alamat.toLowerCase().contains(_query) ||
            v.deskripsi.toLowerCase().contains(_query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _searchBar(),
            ),

            const SizedBox(height: 20),

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
                  _applySearch();
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

  Widget _vendorCard(VendorModel vendor) {
    String displayDeskripsi = vendor.deskripsi;
    if (displayDeskripsi.length > 50) {
      displayDeskripsi = '${displayDeskripsi.substring(0, 50)}...';
    }

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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayDeskripsi,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
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