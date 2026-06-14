import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/admin_auth_service.dart';
import 'package:projek_akhir/admin/admin_login_page.dart';
import 'package:projek_akhir/admin/admin_main_navigation.dart';

class AdminAuthGate extends StatefulWidget {
  const AdminAuthGate({super.key});

  @override
  State<AdminAuthGate> createState() => _AdminAuthGateState();
}

class _AdminAuthGateState extends State<AdminAuthGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final valid = await AdminAuthService().isSessionValid();
    setState(() {
      _isLoggedIn = valid;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1008),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFd4af37)),
        ),
      );
    }
    return _isLoggedIn
        ? const AdminMainNavigation()
        : const AdminLoginPage();
  }
}
