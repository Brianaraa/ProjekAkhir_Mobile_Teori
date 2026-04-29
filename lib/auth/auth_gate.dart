import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/pages/main_navigation.dart';   // ← Tambahkan import ini

Future<bool> checkSession() async {
  return await AuthStorage.isSessionValid();
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final isValid = await AuthStorage.isSessionValid();

    if (isValid) {
      final currentToken = await AuthStorage.getToken();
      
      if (currentToken != null) {
        final newExpiry = DateTime.now().add(const Duration(hours: 24));
        
        await AuthStorage.saveSession(
          token: currentToken, 
          expiredAt: newExpiry
        );
        print('🔄 Sesi diperpanjang sampai: $newExpiry');
      }
    }

    if (mounted) {
      setState(() {
        _isLoggedIn = isValid;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // PERUBAHAN UTAMA DI SINI:
    return _isLoggedIn ? const MainNavigation() : const LoginPage();
  }
}