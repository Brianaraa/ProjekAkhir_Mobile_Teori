import 'package:flutter/material.dart';
import 'package:projek_akhir/pages/vendor_detail_page.dart';
import 'package:projek_akhir/services/bookmark_repository.dart';
import 'package:projek_akhir/services/vendor_service.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final BookmarkRepository _repository = BookmarkRepository();
  final VendorService _vendorService = VendorService();

  List<dynamic> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repository.getAll();
      setState(() {
        _list = data.map((item) {
          return {
            'vendor_id': item.vendorId,
            'vendor': {
              'nama_vendor': item.namaVendor ?? '-',
              'alamat': item.alamat ?? '-'
            }
          };
        }).toList();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _removeBookmark(String vendorId) async {
    try {
      await _repository.remove(vendorId);
      setState(() {
        _list.removeWhere((e) => e['vendor_id'] == vendorId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil dihapus dari Bookmark'),
            backgroundColor: Color(0xFF884513),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus bookmark')),
      );
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFd4af37)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              TextButton(onPressed: _loadData, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    if (_list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada bookmark',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFd4af37),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _list.length,
        itemBuilder: (context, index) {
          final item = _list[index];
          final vendorData = item['vendor'];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFd4af37)),
                      ),
                    );

                    try {
                      final detailVendor = await _vendorService.getVendorById(item['vendor_id']);
                      if (mounted) Navigator.pop(context);

                      if (detailVendor != null && mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorDetailPage(vendor: detailVendor),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFd4af37).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          
                          child: Center(
                            child: Text(
                              vendorData['nama_vendor'] != null && vendorData['nama_vendor'] != '-'
                                  ? vendorData['nama_vendor'][0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFd4af37),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendorData['nama_vendor'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              Text(
                                vendorData['alamat'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.bookmark_remove_rounded, color: Color(0xFFd4af37)),
                          onPressed: () => _removeBookmark(item['vendor_id']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        title: const Text(
          'Daftar Bookmark',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF884513),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }
}