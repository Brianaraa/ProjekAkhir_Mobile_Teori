import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/models/vendor_models.dart';
import 'package:projek_akhir/pages/booking_page.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/services/booking_service.dart';
import 'package:projek_akhir/services/user_service.dart';
import 'package:projek_akhir/services/vendor_service.dart';
import 'package:projek_akhir/pages/vendor_detail_page.dart';
import 'package:projek_akhir/pages/search_page.dart';
import 'package:projek_akhir/pages/chat_page.dart';
import 'package:projek_akhir/services/chat_service.dart';
import 'package:projek_akhir/pages/converter_page.dart';
import 'package:projek_akhir/pages/features_page.dart';
import 'package:projek_akhir/pages/budget_estimator_page.dart';
import 'package:projek_akhir/pages/map_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:projek_akhir/services/weather_service.dart';
import 'package:projek_akhir/models/weather_model.dart';
import 'package:projek_akhir/models/booking_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _vendorService = VendorService();
  final _bookingService = BookingService();

  List<BookingModel> _upcomingCountdowns = [];
  bool _isLoadingCountdown = true;

  List<VendorModel> _vendors = [];
  bool _isLoading = true;
  String _userName = 'User';

  final DateTime _today = DateTime.now();

  final _weatherService = WeatherService();
  WeatherModel? _weather;
  bool _isLoadingWeather = true;

  final _chatService = ChatService();
  String _aiSummary = '';
  bool _isLoadingAI = true;

  //kalender jawa
  static const List<String> _pasaran = [
    'Kliwon',
    'Legi',
    'Pahing',
    'Pon',
    'Wage',
  ];
  static const List<String> _hariJawa = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];
  static const List<String> _bulanMasehi = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const List<String> _bulanHijriyah = [
    '',
    'Muharram',
    'Safar',
    'Rabi\'ul Awal',
    'Rabi\'ul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawwal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  String get _pasaranHariIni {
    final base = DateTime(2000, 1, 1); // Sabtu Legi
    final diff = _today.difference(base).inDays;
    return _pasaran[diff % 5];
  }

  String get _hariJawaHariIni => _hariJawa[_today.weekday % 7];

  String get _hijriyahDate {
    final hijri = HijriCalendar.now();
    return '${hijri.hDay} ${_bulanHijriyah[hijri.hMonth]} ${hijri.hYear} H';
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
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserName();

    // Fetch data paralel
    await Future.wait([
      _fetchVendorsAsync(),
      _fetchMyBookingsAsync(),
      _fetchWeatherAsync(),
    ]);

    // Jalankan AI setelah data terkumpul
    await _generateAISummary();
  }

  Future<void> _fetchVendorsAsync() async {
    final data = await _vendorService.getVendors();
    if (mounted) {
      setState(() {
        _vendors = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMyBookingsAsync() async {
    try {
      final data = await _bookingService.getMyBookings();

      data.sort((a, b) => a.tanggalAcara.compareTo(b.tanggalAcara));

      if (mounted) {
        setState(() {
          _upcomingCountdowns = data;
          _isLoadingCountdown = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _upcomingCountdowns = [];
          _isLoadingCountdown = false;
        });
      }
    }
  }

  Future<void> _fetchWeatherAsync() async {
    final weather = await _weatherService.getWeather(
      '34.71.01.1001',
    ); // Kode DIY
    if (mounted) {
      setState(() {
        _weather = weather;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('nama');
      if (mounted) {
        setState(() {
          _userName = (name != null && name.isNotEmpty) ? name : 'User';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _userName = 'User');
      }
    }
  }

  Future<void> _generateAISummary() async {
    final cuacaStr = _weather != null
        ? '${_weather!.description}, Suhu: ${_weather!.temperature}°C'
        : 'Cerah Berawan';

    final countdownStr = _upcomingCountdowns.isNotEmpty
        ? 'User memiliki hajatan "${_upcomingCountdowns.first.namaAcara}" dalam ${_sisaHariLabel(_upcomingCountdowns.first.tanggalAcara)}.'
        : 'Belum ada hajatan dalam waktu dekat.';

    final prompt =
        '''
    Hari ini adalah weton $_hariJawaHariIni $_pasaranHariIni, tanggal $_hijriyahDate, dengan cuaca $cuacaStr. 
    Terdapat ${_vendors.length} vendor yang tersedia. 
    $countdownStr
    Berikan 2 kalimat ringkas dan ramah berisi saran/insight persiapan hajatan atau kegiatan hari ini untuk $_userName menurut tradisi nusantara atau secara umum.
    ''';

    final response = await _chatService.sendMessage(prompt);

    if (mounted) {
      setState(() {
        _aiSummary = response;
        _isLoadingAI = false;
      });
    }
  }

  String _sisaHariLabel(DateTime date) {
    final days = date.difference(DateTime.now()).inDays;

    return 'H-$days';
  }

  void _logout() async {
    try {
      await AuthStorage.deleteSession();
      await UserService.logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
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

    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(name),
              const SizedBox(height: 24),

              // _buildAIInsights(),
              const SizedBox(height: 24),

              _buildDateCard(),
              const SizedBox(height: 24),

              const Text(
                'Aksi Cepat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 24),

              // list booking
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hajatan Mendatang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => _go(const BookingPage()),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF352010),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildUpcomingHajatan(),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vendor Tersedia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  GestureDetector(
                    onTap: () => _go(const SearchPage()),
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 84, 52, 27),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _buildVendorList(),
              
              const SizedBox(height: 24),

              // fitur
              _buildFeatureBanner(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_greeting,',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
                  color: const Color(0xFF884513).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.logout,
                  color: Color(0xFF884513),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFd4af37).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Bli-AI Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoadingAI
              ? const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : Text(
                  _aiSummary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF352010),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF884513).withOpacity(0.2),
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
              Icon(Icons.calendar_today, color: Color(0xFFd4af37), size: 14),
              SizedBox(width: 6),
              Text(
                'Sinkronisasi Kalender Hari Ini',
                style: TextStyle(
                  color: Color(0xFFd4af37),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Masehi — besar & Cuaca
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '$_hariJawaHariIni, ${_today.day} '
                  '${_bulanMasehi[_today.month]} ${_today.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (!_isLoadingWeather && _weather != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${_weather!.temperature}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 10),

          // Jawa
          _dateRow('Jawa', '$_hariJawaHariIni $_pasaranHariIni'),

          const SizedBox(height: 6),

          // Hijriyah
          _dateRow('Hijriyah', _hijriyahDate),

          const SizedBox(height: 12),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFd4af37).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFd4af37).withOpacity(0.4),
              ),
            ),
            child: Text(
              '$_hariJawaHariIni $_pasaranHariIni',
              style: const TextStyle(
                color: Color(0xFFd4af37),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
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
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),

        Text(
          ' : ',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
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
          ],
        ),
      );
    }

    final hajatan = _upcomingCountdowns.first;

    return GestureDetector(
      onTap: () => _go(const BookingPage()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hajatan.namaAcara,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${hajatan.tanggalAcara.day} ${_bulanMasehi[hajatan.tanggalAcara.month]} ${hajatan.tanggalAcara.year}',
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
                    _sisaHariLabel(hajatan.tanggalAcara),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => a['page'] as Widget),
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
                    color: const Color(0xFFd4af37).withOpacity(0.2),
                  ),
                ),

                child: Icon(
                  a['icon'] as IconData,
                  color: const Color(0xFFd4af37),
                  size: 22,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                a['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
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
          child: Text('Belum ada vendor', style: TextStyle(color: Colors.grey)),
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
                          color: const Color(0xFF884513).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Center(
                          child: Text(
                            v.namaVendor[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF352010),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: Colors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    v.namaVendor,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),

                  Text(
                    v.alamat,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
          border: Border.all(color: const Color(0xFFd4af37).withOpacity(0.25)),
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
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bli-AI, Game & Sensor',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kuis adat, acak kursi, balance game & lebih',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: Color(0xFFd4af37),
            ),
          ],
        ),
      ),
    );
  }
}
