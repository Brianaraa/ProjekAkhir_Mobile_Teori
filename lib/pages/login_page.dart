import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_gate.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/pages/sign_up.dart';
import 'package:projek_akhir/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isVisible = false;
  bool _isLoading = false;

  void login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();


    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);   // Tambahkan ini agar tombol tidak bisa diklik 2x

    try {
      final userService = UserService();
      final result = await userService.login(email, password);

      if (result == null) {
        throw Exception('Email atau password salah');
      }

      // Simpan nama user
      final user = result['user'] as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();

      // ✅ SIMPAN SEMUA DATA USER
      await prefs.setString('user_id', user['uuid']);   // penting untuk update
      await prefs.setString('nama', user['nama']);
      await prefs.setString('email', user['email']);

      await UserService.saveCurrentUserName(user['nama']);
      

      // Simpan session
      final token = result['token'] as String;
      final expiredAt = DateTime.now().add(const Duration(hours: 24));
      await AuthStorage.saveSession(token: token, expiredAt: expiredAt);


      // Jika berhasil, AuthGate akan otomatis redirect ke HomePage
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan';

      if (e.toString().contains('salah')) {
        errorMessage = 'Email atau password salah';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak bisa terhubung ke server';
      } else {
        errorMessage = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffcf9f8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Silakan masuk untuk melanjutkan perjalanan Anda.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 50),

                // === KOTAK FORM DENGAN BACKGROUND ===
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xfff6f3f2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      const Text(
                        "Alamat Email",
                        style: TextStyle(fontSize: 13, color: Color(0xff000000), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _emailField(),

                      const SizedBox(height: 20),

                      // Password
                      const Text(
                        "Kata Sandi",
                        style: TextStyle(fontSize: 13, color: Color(0xff000000), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _passwordField(),

                      const SizedBox(height: 32),

                      // Tombol Login
                      ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFd4af37),
                          foregroundColor: Color(0xFF884513),
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),                   
                    ],
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Belum memiliki akun?",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                        
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
  
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      
      decoration: InputDecoration(
        hintText: 'nama@gmail.com',
        hintStyle: const TextStyle(color: Colors.grey),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isVisible,
      enabled: !_isLoading,
      
      decoration: InputDecoration(
        hintText: '********',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        suffixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: IconButton(
            icon: Icon(
              _isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}