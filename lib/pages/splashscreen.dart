import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / icon app
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.celebration, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hagati',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hajatan & Adat Digital',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFFd4af37),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}