import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SeatingPage extends StatefulWidget {
  const SeatingPage({super.key});

  @override
  State<SeatingPage> createState() => _SeatingPageState();
}

class _SeatingPageState extends State<SeatingPage> {
  StreamSubscription<AccelerometerEvent>? _subscription;

  // Daftar tamu dummy — nanti bisa dari Supabase
  List<String> _guests = [
    'Budi Santoso', 'Siti Rahayu', 'Ahmad Fauzi', 'Dewi Lestari',
    'Eko Prasetyo', 'Fitri Handayani', 'Gunawan', 'Hani Pertiwi',
    'Irwan Setiawan', 'Joko Widodo', 'Kartini', 'Luthfi Hakim',
  ];
  List<String> _shuffled = [];

  bool _isShaking = false;
  bool _isLocked = false;
  DateTime _lastShake = DateTime.now();

  // Threshold guncangan
  static const double _shakeThreshold = 15.0;
  static const int _shakeCooldown = 2000; // ms

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(_guests);
    _startListening();
  }

  void _startListening() {
    _subscription = accelerometerEventStream().listen((event) {
      if (_isLocked) return;

      final magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      final now = DateTime.now();
      final elapsed =
          now.difference(_lastShake).inMilliseconds;

      // Kurangi gravitasi (~9.8) untuk dapat akselerasi murni
      if (magnitude - 9.8 > _shakeThreshold &&
          elapsed > _shakeCooldown) {
        _lastShake = now;
        _onShake();
      }
    });
  }

  void _onShake() {
    setState(() => _isShaking = true);
    _shuffleGuests();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isShaking = false);
    });
  }

  void _shuffleGuests() {
    final list = List<String>.from(_shuffled);
    list.shuffle(Random());
    setState(() => _shuffled = list);
  }

  void _toggleLock() {
    setState(() => _isLocked = !_isLocked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLocked
            ? '🔒 Susunan kursi dikunci'
            : '🔓 Susunan kursi dibuka'),
        duration: const Duration(seconds: 1),
        backgroundColor: _isLocked
            ? const Color(0xFF884513)
            : Colors.grey[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        title: const Text(
          'Atur Kursi Tamu',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              color: _isLocked
                  ? const Color(0xFF884513)
                  : Colors.grey,
            ),
            onPressed: _toggleLock,
          ),
        ],
      ),
      body: Column(
        children: [
          // Instruksi shake
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isShaking
                  ? const Color(0xFFd4af37).withOpacity(0.2)
                  : const Color(0xFFd4af37).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFd4af37).withOpacity(
                    _isShaking ? 0.8 : 0.3),
                width: _isShaking ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _isShaking ? 0.05 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: const Icon(Icons.phone_android,
                      color: Color(0xFFd4af37), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLocked
                            ? '🔒 Susunan dikunci'
                            : _isShaking
                                ? '✨ Mengacak...'
                                : '🔀 Guncang HP untuk acak kursi!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF884513),
                        ),
                      ),
                      Text(
                        '${_shuffled.length} tamu · Tap kunci untuk menyimpan',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grid kursi
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.4,
              ),
              itemCount: _shuffled.length,
              itemBuilder: (context, i) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200 + (i * 30)),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isShaking
                          ? const Color(0xFFd4af37).withOpacity(0.5)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFd4af37).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFd4af37),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _shuffled[i],
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Tombol acak manual
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isLocked ? null : _shuffleGuests,
              icon: const Icon(Icons.shuffle),
              label: const Text('Acak Manual',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLocked ? Colors.grey : const Color(0xFFd4af37),
                foregroundColor: const Color(0xFF884513),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}