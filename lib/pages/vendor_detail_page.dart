import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorDetailPage extends StatelessWidget {
  final VendorModel vendor;

  const VendorDetailPage({super.key, required this.vendor});

  Future<void> _openSosmed(BuildContext context) async {
    final url = Uri.tryParse(vendor.sosmed);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka link')),
        );
      }
    }
  }

  Future<void> _saveToHajatan(BuildContext context) async {
    await NotificationService().showNow(
      id: vendor.id.hashCode,
      title: 'Vendor Disimpan ✓',
      body: '${vendor.namaVendor} ditambahkan ke hajatanmu.',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${vendor.namaVendor} disimpan!'),
          backgroundColor: const Color(0xFF884513),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: CustomScrollView(
        slivers: [
          // ── APP BAR dengan mini map ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFd4af37),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                      vendor.latitude, vendor.longitude),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none, // non-interaktif
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.projek_akhir',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                            vendor.latitude, vendor.longitude),
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFd4af37),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: const Icon(Icons.store,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── KONTEN DETAIL ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + kategori
                  Text(
                    vendor.namaVendor,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd4af37).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vendor.deksripsi,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF884513),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Info rows
                  _infoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    value: vendor.alamat,
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    icon: Icons.link,
                    label: 'Sosial Media',
                    value: vendor.sosmed,
                    isLink: true,
                    onTap: () => _openSosmed(context),
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    icon: Icons.my_location,
                    label: 'Koordinat',
                    value:
                        '${vendor.latitude.toStringAsFixed(6)}, ${vendor.longitude.toStringAsFixed(6)}',
                  ),

                  const SizedBox(height: 28),

                  // Tombol simpan
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveToHajatan(context),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text(
                        'Tambahkan ke Hajatan',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd4af37),
                        foregroundColor: const Color(0xFF884513),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol buka di maps eksternal
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(
                            'https://www.openstreetmap.org/?mlat=${vendor.latitude}&mlon=${vendor.longitude}#map=16/${vendor.latitude}/${vendor.longitude}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Buka di Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF884513),
                        side: const BorderSide(
                            color: Color(0xFFd4af37), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFd4af37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFd4af37), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLink
                        ? const Color(0xFFd4af37)
                        : const Color(0xFF1C1C1C),
                    decoration: isLink
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}