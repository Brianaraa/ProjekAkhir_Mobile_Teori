import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/models/countdown_model.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/pages/countdown_page.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/services/countdown_service.dart';
import 'package:projek_akhir/services/user_service.dart';
import 'package:projek_akhir/services/vendor_service.dart';
import 'package:projek_akhir/pages/vendor_detail_page.dart';
import 'package:projek_akhir/pages/search_page.dart';
import 'package:projek_akhir/pages/chat_page.dart';
import 'package:projek_akhir/pages/converter_page.dart';
import 'package:projek_akhir/pages/features_page.dart';
import 'package:projek_akhir/pages/budget_estimator_page.dart';
import 'package:projek_akhir/pages/map_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _vendorService = VendorService();
  final _countdownService = CountdownService();

  List<CountdownModel> _upcomingCountdowns = []; //simpen yang sudah difilrer
  bool _isLoadingCountdown = true;

  List<VendorModel> _vendors = [];
  bool _isLoading = true;
  String _userName = 'User';

  final DateTime _today = DateTime.now();

  

  // ── Kalender Jawa ──────────────────────────────────────────
  static const List<String> _pasaran = [
    'Kliwon', 'Legi', 'Pahing', 'Pon', 'Wage'
  ];
  static const List<String> _hariJawa = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];
  static const List<String> _bulanMasehi = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  static const List<String> _bulanHijriyah = [
    '', 'Muharram', 'Safar', 'Rabi\'ul Awal', 'Rabi\'ul Akhir',
    'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
    'Ramadhan', 'Syawwal', 'Dzulqa\'dah', 'Dzulhijjah'
  ];

  String get _pasaranHariIni {
    final base = DateTime(2000, 1, 1); // Sabtu Legi
    final diff = _today.difference(base).inDays;
    return _pasaran[diff % 5];
  }

  String get _hariJawaHariIni => _hariJawa[_today.weekday % 7];

  Map<String, int> get _hijriyah {
    final jd = _julianDay(_today);
    const epoch = 1948439.5;
    final n = ((jd - epoch + 0.5) / 29.53059).floor();
    int hy = ((n - 1) / 12).floor() + 1;
    int hm = ((n - 1) % 12) + 1;
    final ms = _julianDay(_hijriToGreg(hy, hm, 1));
    int hd = (jd - ms).floor() + 1;
    if (hd < 1) {
      hm--;
      if (hm < 1) { hm = 12; hy--; }
      hd = 29;
    }
    return {'day': hd, 'month': hm, 'year': hy};
  }

  double _julianDay(DateTime d) {
    int y = d.year, m = d.month;
    if (m <= 2) { y--; m += 12; }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() + d.day + b - 1524.5;
  }

  DateTime _hijriToGreg(int hy, int hm, int hd) {
    final n = hd +
        (29.5001 * (hm - 1)).ceil() +
        (hy - 1) * 354 +
        (3 * ((hy - 1) / 30 + 1)).floor() ~/ 1 +
        1948440 - 385;
    int j = n + 1402;
    int k = (j - 1) ~/ 1461 * 4 + 3;
    final i = ((j - 1) % 1461) ~/ 365;
    final l = i - (i ~/ 365);
    final y1 = k ~/ 4 * 100 + l ~/ 36525;
    final m1 = (l % 36525) ~/ 30 + 1;
    final d1 = (l % 36525) % 30 + 1;
    return DateTime(y1, m1, d1);
  }

  // ── Greeting ───────────────────────────────────────────────
  String get _greeting {
    final h = _today.hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  void initState() {
    super.initState();
    _fetchVendors();
    _loadUserName();
    _fetchMyCountdowns();
  }

  Future<void> _fetchMyCountdowns() async {
    try {
      setState(() => _isLoadingCountdown = true);

      final data = await _countdownService.getMyCountdowns();

      // Karena service sudah difilter, tidak perlu filter lagi
      data.sort((a, b) => a.tanggal.compareTo(b.tanggal)); // pastikan terurut

      setState(() {
        _upcomingCountdowns = data;     // Langsung pakai
        _isLoadingCountdown = false;
      });
    } catch (e) {
      print('Error fetch countdowns: $e');
      setState(() {
        _upcomingCountdowns = [];
        _isLoadingCountdown = false;
      });
    }
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_id');

      if (uuid == null || uuid.isEmpty) {
        setState(() => _userName = 'User');
        return;
      }

      final name = await UserService.getUserNameByUuid(uuid);

      if (mounted) {
        setState(() {
          _userName = name ?? 'User';
        });
      }
    } catch (e) {
      print('Error load user name: $e');
      if (mounted) {
        setState(() => _userName = 'User');
      }
    }
  }

  Future<void> _fetchVendors() async {
    final data = await _vendorService.getVendors();
    setState(() {
      _vendors = data;
      _isLoading = false;
    });
  }

  void _logout() async {
    try {
      await AuthStorage.deleteSession();
      await UserService.logout();        // ← TAMBAHKAN INI

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),  // LoginPage, bukan AuthGate
          (route) => false,
        );
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final name = _userName;
    final hijri = _hijriyah;

    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 1. HEADER ──────────────────────────────────
              _buildHeader(name),
              const SizedBox(height: 24),

              // ── 2. DATE SYNC CARD ──────────────────────────
              _buildDateCard(hijri),
              const SizedBox(height: 24),

              // ── 3. AKSI CEPAT ──────────────────────────────
              const Text('Aksi Cepat',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 24),

              // ── 5. Hajatan mendatang ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hajatan Mendatang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _go(const CountdownPage()), // atau halaman daftar hajatan
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFd4af37),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildUpcomingHajatan(),
              const SizedBox(height: 24),

              // ── 4. VENDOR ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vendor Tersedia',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => _go(const SearchPage()),
                    child: const Text('Lihat semua →',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFFd4af37))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildVendorList(),
              const SizedBox(height: 24),

            // ── 5. BANNER FITUR ────────────────────────────
              _buildFeatureBanner(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // WIDGETS
  // ──────────────────────────────────────────────────────────

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_greeting,',
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            Text(name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            // Logout
            GestureDetector(
              onTap: _logout,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout,
                    color: Colors.red, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateCard(Map<String, int> hijri) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1810), Color(0xFF5C3317)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C1810).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: const [
              Icon(Icons.calendar_today,
                  color: Color(0xFFd4af37), size: 14),
              SizedBox(width: 6),
              Text(
                'Sinkronisasi Kalender Hari Ini',
                style: TextStyle(
                    color: Color(0xFFd4af37),
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Masehi — besar
          Text(
            '$_hariJawaHariIni, ${_today.day} '
            '${_bulanMasehi[_today.month]} ${_today.year}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 10),

          // Jawa
          _dateRow('Jawa',
              '$_hariJawaHariIni $_pasaranHariIni'),

          const SizedBox(height: 6),

          // Hijriyah
          _dateRow(
            'Hijriyah',
            '${hijri['day']} ${_bulanHijriyah[hijri['month']!]} '
            '${hijri['year']} H',
          ),

          const SizedBox(height: 12),

          // Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFd4af37).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFd4af37).withOpacity(0.4)),
            ),
            child: Text(
              '✨ $_hariJawaHariIni $_pasaranHariIni',
              style: const TextStyle(
                  color: Color(0xFFd4af37),
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ),
        Text(' : ',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 12)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildUpcomingHajatan() {
    if (_isLoadingCountdown) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFd4af37)),
      );
    }

    if (_upcomingCountdowns.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: const [
            Icon(Icons.event_busy, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Belum ada hajatan mendatang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'Hajatan yang sudah lewat tidak ditampilkan di sini',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final hajatan = _upcomingCountdowns.first;

    return GestureDetector(
      onTap: () => _go(const CountdownPage()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hajatan.judul,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hajatan.tanggal.day} ${_bulanMasehi[hajatan.tanggal.month]} ${hajatan.tanggal.year}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'SISA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFd4af37),
                    ),
                  ),
                  Text(
                    hajatan.sisaHariLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFd4af37),
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

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.search,
        'label': 'Cari Vendor',
        'page': const SearchPage(),
      },
      {
        'icon': Icons.auto_awesome,
        'label': 'Bli-AI Guide',
        'page': const ChatPage(),
      },
      {
        'icon': Icons.map_outlined,
        'label': 'Peta Vendor',
        'page': const MapPage(),
      },
      {
        'icon': Icons.currency_exchange,
        'label': 'Konversi',
        'page': const ConverterPage(),
      },
      {
        'icon': Icons.calculate_outlined,
        'label': 'Est. Budget',
        'page': const BudgetEstimatorPage(),
      },
    ];

    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 6,
      children: actions.map((a) {
        return GestureDetector(
          onTap: () => 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => a['page'] as Widget,
              ),
            ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFd4af37).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFd4af37).withOpacity(0.2)),
                ),
                child: Icon(a['icon'] as IconData,
                    color: const Color(0xFFd4af37), size: 22),
              ),
              const SizedBox(height: 5),
              Text(
                a['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 9, color: Colors.grey),
                maxLines: 2,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVendorList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFd4af37)),
      );
    }

    if (_vendors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Belum ada vendor',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _vendors.length,
        itemBuilder: (context, i) {
          final v = _vendors[i];
          return GestureDetector(
            onTap: () => _go(VendorDetailPage(vendor: v)),
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFd4af37)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            v.namaVendor[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFd4af37),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          size: 11, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    v.namaVendor,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    v.alamat,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureBanner() {
    return GestureDetector(
      onTap: () => _go(const FeaturesPage()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFd4af37).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFd4af37).withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bli-AI, Game & Sensor',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text(
                    'Kuis adat, acak kursi, balance game & lebih',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 13, color: Color(0xFFd4af37)),
          ],
        ),
      ),
    );
  }
}