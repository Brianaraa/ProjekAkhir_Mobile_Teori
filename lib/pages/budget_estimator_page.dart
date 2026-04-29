import 'package:flutter/material.dart';
import 'package:projek_akhir/widgets/gold_button.dart';

class BudgetEstimatorPage extends StatefulWidget {
  const BudgetEstimatorPage({super.key});

  @override
  State<BudgetEstimatorPage> createState() => _BudgetEstimatorPageState();
}

class _BudgetEstimatorPageState extends State<BudgetEstimatorPage> {
  double _jumlahTamu = 100;
  String _lokasi = 'Kabupaten';
  String _jenisAcara = 'Pernikahan';
  bool _isEstimating = false;
  Map<String, int>? _result;

  final List<String> _lokasiOptions = [
    'Pedesaan',
    'Kabupaten',
    'Kota Besar',
  ];

  final List<Map<String, dynamic>> _acaraOptions = [
    {'label': 'Pernikahan', 'icon': Icons.favorite},
    {'label': 'Sunatan', 'icon': Icons.child_care},
    {'label': 'Selamatan', 'icon': Icons.restaurant},
    {'label': 'Mitoni', 'icon': Icons.pregnant_woman},
  ];

  // Multiplier berdasarkan lokasi
  double get _lokasiMultiplier {
    switch (_lokasi) {
      case 'Pedesaan':  return 0.7;
      case 'Kabupaten': return 1.0;
      case 'Kota Besar': return 1.6;
      default: return 1.0;
    }
  }

  // Base cost per tamu berdasarkan jenis acara (IDR)
  int get _baseCostPerGuest {
    switch (_jenisAcara) {
      case 'Pernikahan': return 150000;
      case 'Sunatan':    return 100000;
      case 'Selamatan':  return 60000;
      case 'Mitoni':     return 75000;
      default: return 100000;
    }
  }

  void _estimate() async {
    setState(() => _isEstimating = true);

    // Simulasi delay kalkulasi
    await Future.delayed(const Duration(milliseconds: 800));

    final tamu = _jumlahTamu.round();
    final base = (_baseCostPerGuest * _lokasiMultiplier).round();
    final totalBase = tamu * base;

    // Breakdown persentase per kategori
    setState(() {
      _result = {
        'Katering':    (totalBase * 0.40).round(),
        'Dekorasi':    (totalBase * 0.20).round(),
        'Gedung':      (totalBase * 0.15).round(),
        'Fotografer':  (totalBase * 0.10).round(),
        'Undangan':    (totalBase * 0.05).round(),
        'Lain-lain':   (totalBase * 0.10).round(),
      };
      _isEstimating = false;
    });
  }

  String _formatRupiah(int amount) {
    String str = amount.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  int get _totalEstimasi =>
      _result?.values.fold(0, (a, b) => a! + b) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        title: const Text(
          'Estimasi Budget',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimasi Budget Hajatan',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Kalkulasi otomatis berdasarkan skala acara',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),

            const SizedBox(height: 28),

            // ── FORM INPUT ──
            _formCard(),

            const SizedBox(height: 20),

            GoldButton(
              label: 'Hitung Estimasi',
              isLoading: _isEstimating,
              icon: Icons.calculate_outlined,
              onPressed: _estimate,
            ),

            // ── HASIL ──
            if (_result != null) ...[
              const SizedBox(height: 28),
              _resultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xfff6f3f2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jumlah tamu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah Tamu',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFd4af37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_jumlahTamu.round()} orang',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF884513),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _jumlahTamu,
            min: 50,
            max: 1000,
            divisions: 19,
            activeColor: const Color(0xFFd4af37),
            inactiveColor: Colors.grey.shade300,
            onChanged: (val) {
              setState(() {
                _jumlahTamu = val;
                _result = null; // reset hasil saat input berubah
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text('1000', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),

          const SizedBox(height: 20),

          // Lokasi
          const Text(
            'Lokasi Acara',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: _lokasiOptions.map((loc) {
              final isActive = _lokasi == loc;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _lokasi = loc;
                    _result = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFd4af37)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFd4af37)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      loc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive
                            ? const Color(0xFF884513)
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Jenis acara
          const Text(
            'Jenis Acara',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            physics: const NeverScrollableScrollPhysics(),
            children: _acaraOptions.map((acara) {
              final isActive = _jenisAcara == acara['label'];
              return GestureDetector(
                onTap: () => setState(() {
                  _jenisAcara = acara['label'];
                  _result = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFd4af37)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFd4af37)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        acara['icon'] as IconData,
                        size: 16,
                        color: isActive
                            ? const Color(0xFF884513)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        acara['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? const Color(0xFF884513)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _resultCard() {
    final total = _totalEstimasi;
    final colors = [
      const Color(0xFFd4af37),
      const Color(0xFF884513),
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.grey,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Estimasi',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatRupiah(total),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4af37),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            '${_jumlahTamu.round()} tamu · $_jenisAcara · $_lokasi',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // Stacked bar chart
          _stackedBar(total, colors),

          const SizedBox(height: 20),

          // Legend breakdown
          ...List.generate(_result!.entries.length, (i) {
            final entry = _result!.entries.elementAt(i);
            final pct = (entry.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatRupiah(entry.value),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.amber[700], size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Estimasi kasar. Harga aktual dapat berbeda tergantung vendor & kondisi lokal.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stackedBar(int total, List<Color> colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 16,
        child: Row(
          children: List.generate(_result!.entries.length, (i) {
            final entry = _result!.entries.elementAt(i);
            final fraction = entry.value / total;
            return Flexible(
              flex: (fraction * 1000).round(),
              child: Container(color: colors[i % colors.length]),
            );
          }),
        ),
      ),
    );
  }
}