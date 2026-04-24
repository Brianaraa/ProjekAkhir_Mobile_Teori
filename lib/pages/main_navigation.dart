import 'package:flutter/material.dart';
import 'package:projek_akhir/pages/converter_page.dart';
import 'package:projek_akhir/pages/home_page.dart';
import 'package:projek_akhir/pages/profile_page.dart';
import 'package:projek_akhir/pages/features_page.dart';
import 'package:projek_akhir/pages/map_page.dart';
import 'package:projek_akhir/pages/notification_page.dart';
import 'package:projek_akhir/pages/search_page.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Tambah halaman lain nanti saat Si A selesai modul masing-masing
  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const MapPage(),        
    const FeaturesPage(),
    const ConverterPage(),
    const NotificationPage(),
    const ProfilePage(),
  ];

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
        type: BottomNavigationBarType.fixed, // Tetap fixed agar muat 4 item
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          // 2. Tambahkan Item Navigasi Baru untuk Fitur Interaktif
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