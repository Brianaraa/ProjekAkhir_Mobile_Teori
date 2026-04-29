import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_gate.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passCheckController = TextEditingController();

  bool _isVisible = false;
  bool _isLoading = false;

  void signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final passCheck = _passCheckController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || passCheck.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pass != passCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak sama'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userService = UserService();
      final user = await userService.register(name, email, pass);

      if (user != null) {
        // Ambil uuid dari response Supabase
        final String? uuid = user['uuid'] as String?;

        if (uuid == null || uuid.isEmpty) {
          throw Exception('UUID tidak ditemukan dari server');
        }

        // Simpan hanya uuid ke SharedPreferences (Single Source of Truth)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', uuid);

        // Opsional: simpan token session
        final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
        final expiredAt = DateTime.now().add(const Duration(hours: 24));
        await AuthStorage.saveSession(token: token, expiredAt: expiredAt);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );

        // Redirect ke AuthGate
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah terdaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('SignUp Error: $e'); // Untuk debugging

      String errorMessage = 'Terjadi kesalahan saat mendaftar';

      if (e.toString().contains('UUID')) {
        errorMessage = 'Gagal mendapatkan data akun';
      } else if (e.toString().contains('SocketException') || 
                e.toString().contains('Failed host lookup')) {
        errorMessage = 'Tidak dapat terhubung ke server';
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hagati",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "TRADISI DALAM MODERNITAS",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xfff6f3f2),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Nama Lengkap",),
                      _nameField(),

                      _label("Email"),
                      _emailField(),

                      _label("Password"),
                      _passwordField(),

                      _label("Konfirmasi Password"),
                      _passCheckField(),

                      const SizedBox(height: 25),

                      ElevatedButton(
                        onPressed: _isLoading ? null : signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFd4af37),
                          foregroundColor: Color(0xFF884513),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Daftar"),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun?",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                        
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
  
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF884513),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xff000000), fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameController,
      decoration: _inputDecoration("Budi Doremi"),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      decoration: _inputDecoration("email@gmail.com"),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isVisible,
      decoration: _inputDecoration("********").copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _passCheckField() {
    return TextField(
      controller: _passCheckController,
      obscureText: true,
      decoration: _inputDecoration("********"), 
    );
  }
}