import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/pages/login_page.dart';

import 'package:projek_akhir/pages/converter_page.dart';
import 'package:projek_akhir/pages/home_page.dart';
import 'package:projek_akhir/pages/profile_page.dart';
import 'package:projek_akhir/pages/search_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  Timer? _sessionTimer;

  // Pages harus sinkron 1:1 dengan nav items di bawah
  final List<Widget> _pages = [
    const HomePage(),      // 0 → Beranda
    const SearchPage(),    // 1 → Eksplor
    const ConverterPage(), // 2 → Konversi
    const ProfilePage(),   // 3 → Profil
  ];

  @override
  void initState() {
    super.initState();
    _startSessionChecker();
  }

  void _startSessionChecker() {
    // Cek session setiap 5 menit
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      final isValid = await AuthStorage.isSessionValid();
      if (!isValid && mounted) {
        _autoLogout();
      }
    });
  }

  Future<void> _autoLogout() async {
    await AuthStorage.deleteSession();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login telah berakhir. Silakan masuk kembali.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Fungsi ini bisa kamu panggil dari halaman Profile untuk Logout Manual
  Future<void> logout() async {
    _sessionTimer?.cancel();
    await _autoLogout();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFd4af37),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Eksplor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange_outlined),
            activeIcon: Icon(Icons.currency_exchange),
            label: 'Konversi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}