import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek_akhir/models/layanan_model.dart';
import 'package:projek_akhir/models/review_model.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/services/bookmark_repository.dart';
import 'package:projek_akhir/services/layanan_services.dart';
import 'package:projek_akhir/services/review_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projek_akhir/pages/map_page.dart';

class VendorDetailPage extends StatefulWidget {
  final VendorModel vendor;

  const VendorDetailPage({
    super.key,
    required this.vendor,
  });

  @override
  State<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage> {
  final LayananService _layananService = LayananService();
  final ReviewService _reviewService = ReviewService();

  bool isBookmarked = false;
  bool isLoadingBookmark = true;

  List<LayananModel> layananList = [];
  bool isLoadingLayanan = true;

  double ratingAvg = 0;
  int ratingCount = 0;

  List<ReviewModel> reviews = [];
  bool isLoadingReviews = true;

  ReviewModel? myReview;

  double? get _minHarga {
    if (layananList.isEmpty) return null;

    final hargaList = layananList
        .where((l) => l.harga != null && l.harga! > 0)
        .map((l) => l.harga!)
        .toList();

    if (hargaList.isEmpty) return null;

    hargaList.sort();
    return hargaList.first;
  }

  String get _minHargaFormatted {
    final harga = _minHarga;
    if (harga == null) return 'Harga belum ada';

    return 'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBookmark();
  }

  

  Future<void> _loadData() async {
    setState(() {
      isLoadingReviews = true;
      isLoadingLayanan = true;
    });

    try {
      final userId = await _reviewService.getCurrentUserId();
      reviews = await _reviewService.getReviewsByVendor(widget.vendor.uuid);

      final summary = await _reviewService.getVendorSummary(widget.vendor.uuid);
      if (summary != null) {
        ratingAvg = (summary['rating_avg'] ?? 0).toDouble();
        ratingCount = summary['rating_count'] ?? 0;
      }

      if (userId != null) {
        myReview = reviews.firstWhere((r) => r.userId == userId);
      }

      layananList = await _layananService.getLayananByVendor(widget.vendor.uuid);

      try {
    final bookmarkRepo = BookmarkRepository();

    final allBookmarks = await bookmarkRepo.getAll();
    
    setState(() {
      isBookmarked = allBookmarks.any((b) => b.vendorId == widget.vendor.uuid);
    });
  } catch (e) {
    print('❌ Error loading bookmark: $e');
  }

    } catch (e) {
      print('❌ Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingReviews = false;
          isLoadingLayanan = false;
        });
      }
    }
  }

  Future<void> _loadBookmark() async {
    try {
      final repo = BookmarkRepository();
      final all = await repo.getAll(); 

      if (mounted) {
        setState(() {
          isBookmarked = all.any((item) => item.vendorId == widget.vendor.uuid);
          isLoadingBookmark = false;
        });
      }
    } catch (e) {
      print('❌ Error load bookmark: $e');
    }
  }

  Future<void> _openSosmed() async {
    final username = widget.vendor.sosmed;

    if (username == null || username.isEmpty) return;

    final cleanUsername = username
        .replaceAll('@', '')
        .replaceAll('https://www.instagram.com/', '')
        .replaceAll('instagram.com/', '');

    final appUri = Uri.parse('instagram://user?username=$cleanUsername');
    final webUri = Uri.parse('https://www.instagram.com/$cleanUsername');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error buka IG: $e');
    }
  }

  void _showReviewDialog() {
    final commentController =
        TextEditingController(text: myReview?.komentar ?? '');
    double rating = myReview?.rating ?? 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              backgroundColor: const Color(0xfffcf9f8),
              title: Text(
                myReview == null ? 'Beri Ulasan' : 'Edit Ulasan Anda',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF884513),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sentuh bintang untuk memberi rating",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () {
                          setStateDialog(() {
                            rating = i + 1.0;
                          });
                        },
                        icon: Icon(
                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Bagikan pengalaman Anda menggunakan jasa vendor ini...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFd4af37)),
                      ),

                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF884513)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF884513)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _reviewService.addOrUpdateReview(
                            vendorId: widget.vendor.uuid,
                            rating: rating,
                            komentar: commentController.text,
                          );
                          if (context.mounted) Navigator.pop(context);
                          await _loadData(); 
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFd4af37),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Color(0xFF884513),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLayananCard(LayananModel layanan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: layanan.foto != null && layanan.foto!.isNotEmpty
                ? Image.network(
                    layanan.getFotoUrl(widget.vendor.uuid),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layanan.namaLayanan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (layanan.deskripsi != null && layanan.deskripsi!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      layanan.deskripsi!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 8),

                Text(
                  layanan.hargaFormatted,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF884513),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Future<void> _toggleBookmark() async {
    final repo = BookmarkRepository();

    try {
      if (isBookmarked) {
        await repo.remove(widget.vendor.uuid);

        setState(() {
          isBookmarked = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark dihapus')),
        );
      } else {
        await repo.add(widget.vendor.uuid);

        setState(() {
          isBookmarked = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil dibookmark')),
        );
      }
    } catch (e) {
      print('Toggle error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingAvgDisplay = ratingAvg;
    final ratingCountDisplay = ratingCount;

    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hagati',
          style: TextStyle(
            color: Color(0xFF884513),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                Image.network(
                  _mainImageUrl,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 280,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 60),
                      ),
                    );
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.vendor.namaVendor,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                          _minHargaFormatted,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF884513),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        ratingAvgDisplay.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$ratingCountDisplay Review',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (widget.vendor.deskripsi != null &&
                      widget.vendor.deskripsi!.isNotEmpty)
                    Text(
                      widget.vendor.deskripsi!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),

                  const SizedBox(height: 32),

                  _infoCard(
                    icon: Icons.location_on_outlined,
                    title: 'ALAMAT',
                    content: widget.vendor.alamat,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapPage(
                            initialVendor: widget.vendor,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  if (widget.vendor.sosmed != null &&
                      widget.vendor.sosmed!.isNotEmpty)
                    _infoCard(
                      icon: Icons.link,
                      title: 'SOSIAL MEDIA',
                      content: widget.vendor.sosmed!,
                      onTap: _openSosmed,
                    ),

                  const SizedBox(height: 40),

                  const Text(
                    'Layanan yang Ditawarkan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  if (isLoadingLayanan)
                    const Center(child: CircularProgressIndicator())
                  else if (layananList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('Belum ada layanan yang ditambahkan.'),
                      ),
                    )
                  else
                    Column(
                      children: layananList.map((layanan) => _buildLayananCard(layanan)).toList(),
                    ),

                  const SizedBox(height: 40),

                  const Text(
                    'Apa kata mereka?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showReviewDialog,
                      label: Text(
                        myReview == null ? 'Beri Ulasan Sekarang' : 'Perbarui Ulasan Anda',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF884513),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd4af37).withOpacity(0.2),
                        foregroundColor: const Color(0xFF884513),
                        elevation: 0, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFd4af37), width: 1),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (isLoadingReviews)
                    const Center(child: CircularProgressIndicator())
                  else if (reviews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('Belum ada ulasan untuk vendor ini.'),
                      ),
                    )
                  else
                    Column(
                      children: reviews
                          .map((review) => _buildReviewCard(review))
                          .toList(),
                    ),

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _toggleBookmark,
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(
                        isBookmarked
                            ? 'Hapus Bookmark'
                            : 'Bookmark Hajatan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd4af37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    String formattedDate = '';

    try {
      formattedDate =
          DateFormat('dd MMMM yyyy', 'id_ID').format(review.createdAt);
    } catch (_) {
      formattedDate = DateFormat('dd MMM yyyy').format(review.createdAt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    const Color(0xFFd4af37).withOpacity(0.2),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF884513),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (review.komentar != null &&
              review.komentar!.isNotEmpty)
            Text(
              review.komentar!,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
        ],
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String content, VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF884513)),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String get _mainImageUrl {
    if (widget.vendor.uuid.isEmpty) {
      return 'https://via.placeholder.com/600x400';
    }

    return Supabase.instance.client.storage
        .from('vendor')
        .getPublicUrl('${widget.vendor.uuid}/main_picture.jpg');
  }
}