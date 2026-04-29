import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BalanceGamePage extends StatefulWidget {
  const BalanceGamePage({super.key});

  @override
  State<BalanceGamePage> createState() => _BalanceGamePageState();
}

class _BalanceGamePageState extends State<BalanceGamePage> {
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  Timer? _gameTimer;
  Timer? _difficultyTimer;

  // State game
  double _tiltAngle = 0.0;      // -1.0 (kiri) sampai 1.0 (kanan)
  double _trayPosition = 0.0;   // posisi horizontal tray
  int _score = 0;
  int _timeLeft = 30;
  int _lives = 3;
  int _level = 1;
  bool _isPlaying = false;
  bool _gameOver = false;
  bool _showCountdown = true;
  int _countdown = 3;

  // Batas toleransi tilt (makin kecil = makin susah)
  double get _tolerance => max(0.3, 0.6 - (_level - 1) * 0.08);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        setState(() => _showCountdown = false);
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _gameOver = false;
    });

    // Gyroscope listener
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (!_isPlaying) return;
      setState(() {
        // event.y = rotasi kanan-kiri
        _tiltAngle = (_tiltAngle + event.y * 0.1).clamp(-1.0, 1.0);

        // Cek apakah terlalu miring
        if (_tiltAngle.abs() > _tolerance) {
          _trayPosition = (_tiltAngle * 40).clamp(-80.0, 80.0);
        } else {
          // Auto-balance perlahan jika dalam toleransi
          _tiltAngle *= 0.95;
          _trayPosition *= 0.9;
        }
      });

      // Nyawa berkurang jika tilt ekstrem
      if (_tiltAngle.abs() > 0.85 && _isPlaying) {
        _loseLife();
      }
    });

    // Timer game
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying) return;
      setState(() {
        _timeLeft--;
        // Tambah skor per detik jika stabil
        if (_tiltAngle.abs() < _tolerance * 0.5) _score += _level;
      });

      if (_timeLeft <= 0) _levelUp();
    });
  }

  void _loseLife() {
    setState(() {
      _lives--;
      _tiltAngle = 0;
      _trayPosition = 0;
    });
    if (_lives <= 0) _endGame();
  }

  void _levelUp() {
    setState(() {
      _level++;
      _timeLeft = max(15, 30 - (_level - 1) * 3);
      _score += 10 * _level; // bonus level
    });
  }

  void _endGame() {
    _isPlaying = false;
    _gyroSub?.cancel();
    _gameTimer?.cancel();
    setState(() => _gameOver = true);
  }

  void _restart() {
    _gyroSub?.cancel();
    _gameTimer?.cancel();
    setState(() {
      _tiltAngle = 0;
      _trayPosition = 0;
      _score = 0;
      _timeLeft = 30;
      _lives = 3;
      _level = 1;
      _gameOver = false;
      _showCountdown = true;
      _countdown = 3;
    });
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Balance the Offerings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: _showCountdown
          ? _countdownScreen()
          : _gameOver
              ? _gameOverScreen()
              : _gameScreen(),
    );
  }

  Widget _countdownScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Siapkan dirimu!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            _countdown > 0 ? '$_countdown' : 'Mulai!',
            style: const TextStyle(
              color: Color(0xFFd4af37),
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Miringkan HP untuk menjaga keseimbangan sesaji!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _gameScreen() {
    return Column(
      children: [
        // HUD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nyawa
              Row(
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.favorite,
                    color: i < _lives
                        ? Colors.red
                        : Colors.grey[800],
                    size: 22,
                  ),
                ),
              ),
              // Level
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFd4af37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level $_level',
                  style: const TextStyle(
                      color: Color(0xFFd4af37),
                      fontWeight: FontWeight.bold),
                ),
              ),
              // Skor
              Text(
                'Skor: $_score',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ),

        // Timer bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _timeLeft / 30,
              backgroundColor: Colors.grey[800],
              color: _timeLeft > 10
                  ? const Color(0xFFd4af37)
                  : Colors.red,
              minHeight: 8,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$_timeLeft detik',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),

        // Area game
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background dekoratif
              Positioned(
                bottom: 80,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.star, color: Colors.amber, size: 200),
                ),
              ),

              // Meter keseimbangan (bawah)
              Positioned(
                bottom: 30,
                left: 40,
                right: 40,
                child: _balanceMeter(),
              ),

              // Tray + sesaji (tengah)
              Positioned(
                child: Transform.translate(
                  offset: Offset(_trayPosition * 2, 0),
                  child: Transform.rotate(
                    angle: _tiltAngle * 0.3,
                    child: _trayWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _trayWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sesaji di atas tray
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _offeringItem('🌺', 'Bunga'),
            const SizedBox(width: 8),
            _offeringItem('🍚', 'Tumpeng'),
            const SizedBox(width: 8),
            _offeringItem('🕯️', 'Lilin'),
          ],
        ),
        const SizedBox(height: 8),
        // Tray (tampah)
        Container(
          width: 180,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF8B6914),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
        ),
        // Tiang penyangga
        Container(
          width: 8,
          height: 40,
          color: const Color(0xFF6B4F0F),
        ),
      ],
    );
  }

  Widget _offeringItem(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }

  Widget _balanceMeter() {
    final normalized = (_tiltAngle + 1) / 2; // 0.0 - 1.0
    return Column(
      children: [
        Stack(
          children: [
            // Track
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // Safe zone (tengah)
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: _tolerance,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            // Needle
            Align(
              alignment: Alignment((_tiltAngle).clamp(-1.0, 1.0), 0),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _tiltAngle.abs() < _tolerance
                      ? const Color(0xFFd4af37)
                      : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_tiltAngle.abs() < _tolerance
                              ? const Color(0xFFd4af37)
                              : Colors.red)
                          .withOpacity(0.6),
                      blurRadius: 8,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('◀', style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text(
              _tiltAngle.abs() < _tolerance ? '✓ Stabil' : '⚠ Jaga keseimbangan!',
              style: TextStyle(
                color: _tiltAngle.abs() < _tolerance
                    ? Colors.green
                    : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('▶', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _gameOverScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💀', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Game Over!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor akhir: $_score',
              style: const TextStyle(
                  color: Color(0xFFd4af37), fontSize: 20),
            ),
            Text(
              'Level yang dicapai: $_level',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd4af37),
                foregroundColor: const Color(0xFF884513),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Main Lagi',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kembali',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }
}