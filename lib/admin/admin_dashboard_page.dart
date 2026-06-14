import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/admin_auth_service.dart';
import 'package:projek_akhir/services/admin_vendor_service.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _service = AdminVendorService();
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _recentReviews = [];
  bool _isLoading = true;
  String _adminNama = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final admin = await AdminAuthService().getCurrentAdmin();
    final stats = await _service.getDashboardStats();
    final bookings = await _service.getRecentBookings(limit: 5);
    final reviews = await _service.getRecentReviews(limit: 5);
    if (mounted) {
      setState(() {
        _adminNama = admin?.nama ?? 'Admin';
        _stats = stats;
        _recentBookings = bookings;
        _recentReviews = reviews;
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(dynamic val) {
    if (val == null) return 'Rp 0';
    final number = (val as num).toDouble();
    if (number >= 1000000000) return 'Rp ${(number / 1000000000).toStringAsFixed(1)}M';
    if (number >= 1000000) return 'Rp ${(number / 1000000).toStringAsFixed(1)}jt';
    if (number >= 1000) return 'Rp ${(number / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${number.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1008),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFd4af37)))
            : RefreshIndicator(
                onRefresh: _load,
                color: const Color(0xFFd4af37),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildRevenueCard(),
                      const SizedBox(height: 24),
                      _buildRecentBookings(),
                      const SizedBox(height: 24),
                      _buildRecentReviews(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFd4af37),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.admin_panel_settings,
              color: Color(0xFF1C1008), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat datang,',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 13)),
              Text(_adminNama,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Text(
          DateFormat('dd MMM yyyy').format(DateTime.now()),
          style: TextStyle(
              color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final items = [
      {
        'label': 'Vendor Aktif',
        'value': '${_stats['total_vendor_aktif'] ?? 0}',
        'icon': Icons.store,
        'color': const Color(0xFFd4af37),
      },
      {
        'label': 'Total User',
        'value': '${_stats['total_user'] ?? 0}',
        'icon': Icons.people,
        'color': Colors.teal,
      },
      {
        'label': 'Total Booking',
        'value': '${_stats['total_booking'] ?? 0}',
        'icon': Icons.receipt_long,
        'color': Colors.blue,
      },
      {
        'label': 'Total Review',
        'value': '${_stats['total_review'] ?? 0}',
        'icon': Icons.star,
        'color': Colors.orange,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) {
        final color = item['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C1810),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item['icon'] as IconData, color: color, size: 26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['value'] as String,
                    style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRevenueCard() {
    final revenue = _stats['total_revenue'];
    final paidBookings = _stats['total_booking_paid'] ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFd4af37), Color(0xFFE5C04A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.monetization_on, color: Color(0xFF1C1008), size: 18),
              SizedBox(width: 6),
              Text('Total Revenue',
                  style: TextStyle(
                      color: Color(0xFF1C1008),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatRupiah(revenue),
            style: const TextStyle(
                color: Color(0xFF1C1008),
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Dari $paidBookings booking terbayar',
            style: TextStyle(
                color: const Color(0xFF1C1008).withOpacity(0.6),
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking Terbaru',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_recentBookings.isEmpty)
          _emptyState('Belum ada booking')
        else
          ..._recentBookings.map((b) => _bookingItem(b)),
      ],
    );
  }

  Widget _bookingItem(Map<String, dynamic> b) {
    final isPaid = b['status_bayar'] == 'paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1810),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b['nama_acara'] ?? '-',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(b['nama_vendor'] ?? '-',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPaid ? 'PAID' : 'UNPAID',
              style: TextStyle(
                  color: isPaid ? Colors.green : Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Terbaru',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_recentReviews.isEmpty)
          _emptyState('Belum ada review')
        else
          ..._recentReviews.map((r) => _reviewItem(r)),
      ],
    );
  }

  Widget _reviewItem(Map<String, dynamic> r) {
    final rating = (r['rating'] ?? 0).toDouble();
    final vendorNama = r['vendor']?['nama_vendor'] ?? '-';
    final userName  = r['users']?['nama'] ?? 'User';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1810),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendorNama,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text('oleh $userName',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
                if (r['komentar'] != null)
                  Text(r['komentar'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              Text(rating.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C1810),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(msg,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 14)),
        ),
      );
}
