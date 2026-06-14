import 'package:flutter/material.dart';
import 'package:projek_akhir/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBookingPage extends StatefulWidget {
  const AdminBookingPage({super.key});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late final TabController _tabController;

  List<Map<String, dynamic>> _all      = [];
  List<Map<String, dynamic>> _unpaid   = [];
  List<Map<String, dynamic>> _paid     = [];
  bool _isLoading = true;

  static const List<String> _bulanMasehi = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false);
      final data = List<Map<String, dynamic>>.from(res);
      if (mounted) {
        setState(() {
          _all    = data;
          _unpaid = data.where((b) => b['status_bayar'] == 'unpaid').toList();
          _paid   = data.where((b) => b['status_bayar'] == 'paid').toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '-';
    return '${d.day} ${_bulanMasehi[d.month]} ${d.year}';
  }

  String _formatRupiah(dynamic val) {
    if (val == null) return 'Rp 0';
    final number = (val as num).toDouble();
    if (number >= 1000000) return 'Rp ${(number / 1000000).toStringAsFixed(1)}jt';
    if (number >= 1000) return 'Rp ${(number / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${number.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1008),
      appBar: AppBar(
        title: const Text('Booking'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFd4af37),
          unselectedLabelColor: Colors.white38,
          indicatorColor: const Color(0xFFd4af37),
          tabs: [
            Tab(text: 'Semua (${_all.length})'),
            Tab(text: 'Unpaid (${_unpaid.length})'),
            Tab(text: 'Paid (${_paid.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFd4af37)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_all),
                _buildList(_unpaid),
                _buildList(_paid),
              ],
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Center(
        child: Text('Tidak ada data',
            style: TextStyle(color: Colors.white.withOpacity(0.4))),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFFd4af37),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _bookingCard(list[i]),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> b) {
    final isPaid   = b['status_bayar'] == 'paid';
    final tanggal  = _formatDate(b['tanggal_acara']);
    final createdAt = _formatDate(b['created_at']);
    final harga    = _formatRupiah(b['total_harga']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1810),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? Colors.green.withOpacity(0.25)
              : Colors.orange.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  b['nama_acara'] ?? '-',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'UNPAID',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          _infoRow(Icons.store_outlined, b['nama_vendor'] ?? '-'),
          _infoRow(Icons.room_service_outlined, b['nama_layanan'] ?? '-'),
          _infoRow(Icons.calendar_today_outlined,
              'Tanggal acara: $tanggal'),
          _infoRow(Icons.attach_money, harga),
          _infoRow(Icons.access_time_outlined, 'Dipesan: $createdAt'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFd4af37), size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
