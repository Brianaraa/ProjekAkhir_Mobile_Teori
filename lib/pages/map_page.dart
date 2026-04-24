import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/pages/vendor_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _supabase = Supabase.instance.client;
  final _mapController = MapController();

  List<VendorModel> _vendors = [];
  VendorModel? _selectedVendor;
  bool _isLoading = true;
  String _activeFilter = 'Semua';

  final List<String> _filters = [
    'Semua', 'Katering', 'Dekorasi', 'Fotografer', 'Gedung'
  ];

  // Default center: Yogyakarta
  static const LatLng _defaultCenter = LatLng(-7.7956, 110.3695);

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    try {
      final response = await _supabase.from('vendor').select();
      setState(() {
        _vendors = (response as List)
            .map((e) => VendorModel.fromJson(e))
            .toList();
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

  List<VendorModel> get _filteredVendors {
    if (_activeFilter == 'Semua') return _vendors;
    return _vendors.where((v) =>
        v.deksripsi.toLowerCase().contains(_activeFilter.toLowerCase())
    ).toList();
  }

  void _onMarkerTap(VendorModel vendor) {
    setState(() => _selectedVendor = vendor);
    // Geser peta ke marker yang dipilih
    _mapController.move(
      LatLng(vendor.latitude, vendor.longitude),
      15.0,
    );
  }

  void _closeBottomSheet() {
    setState(() => _selectedVendor = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── PETA FULLSCREEN ──
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFd4af37)),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 13.0,
                    onTap: (_, __) => _closeBottomSheet(),
                  ),
                  children: [
                    // Tile layer OpenStreetMap
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.projek_akhir',
                    ),

                    // Marker layer
                    MarkerLayer(
                      markers: _filteredVendors.map((vendor) {
                        final isSelected = _selectedVendor?.id == vendor.id;
                        return Marker(
                          point: LatLng(vendor.latitude, vendor.longitude),
                          width: isSelected ? 52 : 42,
                          height: isSelected ? 52 : 42,
                          child: GestureDetector(
                            onTap: () => _onMarkerTap(vendor),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF884513)
                                    : const Color(0xFFd4af37),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _categoryIcon(vendor.deksripsi),
                                color: Colors.white,
                                size: isSelected ? 26 : 20,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

          // ── SEARCH BAR + FILTER (overlay atas) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      // Arahkan ke search page
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _VendorSearchDelegate(),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari vendor di sekitarmu...',
                      hintStyle: TextStyle(
                          color: Colors.grey[500], fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFd4af37)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Filter chips
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, i) {
                      final isActive = _activeFilter == _filters[i];
                      return GestureDetector(
                        onTap: () => setState(() {
                          _activeFilter = _filters[i];
                          _selectedVendor = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFd4af37)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isActive
                                  ? const Color(0xFF884513)
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── COUNTER VENDOR (kiri bawah) ──
          Positioned(
            bottom: _selectedVendor != null ? 220 : 20,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Text(
                '${_filteredVendors.length} vendor',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF884513)),
              ),
            ),
          ),

          // ── BOTTOM SHEET VENDOR (saat marker dipilih) ──
          if (_selectedVendor != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _vendorBottomSheet(_selectedVendor!),
            ),
        ],
      ),
    );
  }

  Widget _vendorBottomSheet(VendorModel vendor) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Avatar initial
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFd4af37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    vendor.namaVendor.isNotEmpty
                        ? vendor.namaVendor[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFd4af37),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.namaVendor,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            vendor.alamat,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vendor.deksripsi,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Koordinat
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xfff6f3f2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.my_location,
                          size: 16, color: Color(0xFFd4af37)),
                      const SizedBox(height: 4),
                      Text(
                        '${vendor.latitude.toStringAsFixed(4)},\n${vendor.longitude.toStringAsFixed(4)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Tombol lihat detail
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VendorDetailPage(vendor: vendor),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af37),
                    foregroundColor: const Color(0xFF884513),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Lihat Detail Vendor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String deskripsi) {
    final d = deskripsi.toLowerCase();
    if (d.contains('kater')) return Icons.restaurant;
    if (d.contains('dekor')) return Icons.local_florist;
    if (d.contains('foto') || d.contains('video')) return Icons.camera_alt;
    if (d.contains('gedung') || d.contains('venue') || d.contains('hall')) {
      return Icons.location_city;
    }
    return Icons.store;
  }
}

// ── SEARCH DELEGATE (tap search bar di peta) ──
class _VendorSearchDelegate extends StatefulWidget {
  const _VendorSearchDelegate();

  @override
  State<_VendorSearchDelegate> createState() =>
      _VendorSearchDelegateState();
}

class _VendorSearchDelegateState extends State<_VendorSearchDelegate> {
  final _supabase = Supabase.instance.client;
  final _ctrl = TextEditingController();

  List<VendorModel> _all = [];
  List<VendorModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
    _ctrl.addListener(() {
      final q = _ctrl.text.toLowerCase();
      setState(() {
        _filtered = _all.where((v) =>
            v.namaVendor.toLowerCase().contains(q) ||
            v.alamat.toLowerCase().contains(q)).toList();
      });
    });
  }

  Future<void> _load() async {
    final res = await _supabase.from('vendor').select();
    setState(() {
      _all = (res as List).map((e) => VendorModel.fromJson(e)).toList();
      _filtered = _all;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari nama vendor atau alamat...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filtered.length,
        itemBuilder: (context, i) {
          final v = _filtered[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFd4af37).withOpacity(0.15),
              child: Text(
                v.namaVendor[0].toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFFd4af37),
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(v.namaVendor,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(v.alamat,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing:
                const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.pop(context, v),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}