import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/auth/biometric.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/pages/main_navigation.dart'; 

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

    if (!isValid) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      return;
    }

    final biometricEnabled = await AuthStorage.isBiometricEnabled();

    if (biometricEnabled) {
      final success = await BiometricService.authenticate();

      if (!success) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        return;
      }
    }

    if (!isValid) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(isSessionExpired: true),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoggedIn = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return _isLoggedIn ? const MainNavigation() : const LoginPage();
  }
}