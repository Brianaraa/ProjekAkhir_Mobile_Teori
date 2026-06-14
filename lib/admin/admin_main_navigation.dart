import 'package:flutter/material.dart';
import 'package:projek_akhir/admin/admin_dashboard_page.dart';
import 'package:projek_akhir/admin/admin_vendor_list_page.dart';
import 'package:projek_akhir/admin/admin_booking_page.dart';
import 'package:projek_akhir/admin/admin_profile_page.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _index = 0;

  final _pages = const [
    AdminDashboardPage(),
    AdminVendorListPage(),
    AdminBookingPage(),
    AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: const Color(0xFF1C1008),
        indicatorColor: const Color(0xFFd4af37).withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFFd4af37)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.store, color: Color(0xFFd4af37)),
            label: 'Vendor',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: Colors.white54),
            selectedIcon:
                Icon(Icons.receipt_long, color: Color(0xFFd4af37)),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.white54),
            selectedIcon: Icon(Icons.person, color: Color(0xFFd4af37)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
