import 'package:flutter/material.dart';
import 'package:projek_akhir/models/currency_model.dart';
import 'package:projek_akhir/services/currency_service.dart';
import 'package:projek_akhir/widgets/currency_card.dart';
import 'package:projek_akhir/widgets/timezone_card.dart';
import 'package:projek_akhir/widgets/gold_button.dart';


class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyService = CurrencyService();
  final _nominalController = TextEditingController();

  List<CurrencyModel> rates = [];
  bool isLoadingRates = true;
  bool isConverting = false;
  double inputAmount = 0;
  String lastUpdated = '-';

  // Timezone — kalkulasi lokal, tidak perlu API
  DateTime get _now => DateTime.now().toUtc();
  String get _wib =>
      _formatTime(_now.add(const Duration(hours: 7)));
  String get _wita =>
      _formatTime(_now.add(const Duration(hours: 8)));
  String get _wit =>
      _formatTime(_now.add(const Duration(hours: 9)));
  String get _london => _formatTime(_now); // UTC+0 (non-DST, sesuaikan DST jika perlu)

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    try {
      final data = await currencyService.getRates();
      setState(() {
        rates = data;
        isLoadingRates = false;
        if (data.isNotEmpty) {
          lastUpdated =
              '${data[0].lastUpdated.day}/${data[0].lastUpdated.month}/${data[0].lastUpdated.year} '
              '${data[0].lastUpdated.hour.toString().padLeft(2, '0')}:'
              '${data[0].lastUpdated.minute.toString().padLeft(2, '0')}';
        }
      });
    } catch (e) {
      setState(() => isLoadingRates = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat kurs. Cek koneksi internet.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _convert() {
    final raw = _nominalController.text.trim().replaceAll('.', '');
    final amount = double.tryParse(raw) ?? 0;
    setState(() => inputAmount = amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        title: const Text(
          'Konversi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFd4af37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFd4af37),
          tabs: const [
            Tab(text: 'Mata Uang'),
            Tab(text: 'Zona Waktu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _currencyTab(),
          _timezoneTab(),
        ],
      ),
    );
  }

  // ─── TAB MATA UANG ───────────────────────────────────────
  Widget _currencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konversi dari IDR',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Kurs diperbarui: $lastUpdated',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Form input
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xfff6f3f2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nominal (IDR)',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _nominalField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _convert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af37),
                    foregroundColor: const Color(0xFF884513),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Konversi',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hasil konversi
          if (isLoadingRates)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFd4af37)),
            )
          else
            ...rates.map((rate) => CurrencyCard(
            rate: rate,
            inputAmount: inputAmount,
            )),
        ],
      ),
    );
  }

  Widget _currencyResultCard(CurrencyModel rate) {
    final converted = rate.convert(inputAmount);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: Color(0xFFd4af37), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rate.code,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                rate.name,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                inputAmount == 0
                    ? '1 IDR = ${rate.rate.toStringAsFixed(6)}'
                    : converted.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF884513),
                ),
              ),
              if (inputAmount > 0)
                Text(
                  '1 IDR = ${rate.rate.toStringAsFixed(6)} ${rate.code}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TAB ZONA WAKTU ──────────────────────────────────────
  Widget _timezoneTab() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zona Waktu Sekarang',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Diperbarui otomatis dari perangkat',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        TimezoneCard(
          code: 'WIB',
          fullName: 'Waktu Indonesia Barat',
          time: _wib,
          cities: 'Jakarta · Yogyakarta · Surabaya',
          isBase: true,
        ),
        TimezoneCard(
          code: 'WITA',
          fullName: 'Waktu Indonesia Tengah',
          time: _wita,
          cities: 'Bali · Makassar · Mataram',
        ),
        TimezoneCard(
          code: 'WIT',
          fullName: 'Waktu Indonesia Timur',
          time: _wit,
          cities: 'Jayapura · Ambon · Sorong',
        ),
        TimezoneCard(
          code: 'London',
          fullName: 'Greenwich Mean Time',
          time: _london,
          cities: 'London · Lisbon · Dublin',
        ),
      ],
    ),
  );
}

  Widget _timezoneCard(
      String code, String name, String time, String cities) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff6f3f2),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: Color(0xFFd4af37), width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(code,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(name,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(cities,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFd4af37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nominalField() {
    return TextField(
      controller: _nominalController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Contoh: 1000000',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixText: 'Rp ',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFd4af37), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nominalController.dispose();
    super.dispose();
  }
}