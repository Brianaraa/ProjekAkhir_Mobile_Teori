import 'dart:async';
import 'package:projek_akhir/pages/main_navigation.dart'; // Sesuaikan path folder kamu
import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_local.dart';
import 'package:projek_akhir/pages/home_page.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final biometricService = BiometricService();
  late final StreamSubscription<AuthState> authListener;

  bool isLoading = true;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth(); // Cek pertama kali

    // Listener auth state change
    authListener = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        final event = data.event;

        print('Auth event: $event'); // Untuk debugging

        if (event == AuthChangeEvent.signedOut) {
          if (!mounted) return;
          
          setState(() {
            isAuthenticated = false;
            isLoading = false;
          });
        } 
        else if (event == AuthChangeEvent.signedIn) {
          if (!mounted) return;
          await _checkAuthAfterSignIn(); // Cek biometric jika perlu
        }
      },
    );
  }

  // Cek auth saat pertama kali aplikasi dibuka
  Future<void> _checkInitialAuth() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      await _handleAuthenticatedSession();
    } else {
      _setUnauthenticated();
    }
  }

  // Dipanggil saat user baru sign in
  Future<void> _checkAuthAfterSignIn() async {
    await _handleAuthenticatedSession();
  }

  Future<void> _handleAuthenticatedSession() async {
    bool canUseBio = await biometricService.isBiometricAvailable();

    if (canUseBio) {
      bool success = await biometricService.authenticate();
      if (!mounted) return;

      setState(() {
        isAuthenticated = success;
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isAuthenticated = true;
        isLoading = false;
      });
    }
  }

  void _setUnauthenticated() {
    if (!mounted) return;
    setState(() {
      isAuthenticated = false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFd4af37))),
      );
    }

    // UBAH HomePage() MENJADI MainNavigation() 👇
    return isAuthenticated ? const MainNavigation() : const LoginPage();
  }

  @override
  void dispose() {
    authListener.cancel();
    super.dispose();
  }
}