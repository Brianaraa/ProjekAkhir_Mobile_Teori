import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/admin_auth_service.dart';
import 'package:projek_akhir/admin/admin_main_navigation.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure   = true;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passwordCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _showSnack('Email dan password wajib diisi', Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    final admin = await AdminAuthService().login(email, pass);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (admin != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminMainNavigation()),
      );
    } else {
      _showSnack('Email atau password salah', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1008),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFd4af37),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hagati Admin',
                  style: TextStyle(
                    color: Color(0xFFd4af37),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Panel Manajemen Vendor',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
                const SizedBox(height: 40),

                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C1810),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFd4af37).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Email Admin'),
                      _textField(
                        controller: _emailCtrl,
                        hint: 'admin@hagati.com',
                        icon: Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _label('Password'),
                      _textField(
                        controller: _passwordCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFd4af37),
                            foregroundColor: const Color(0xFF1C1008),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF1C1008), strokeWidth: 2)
                              : const Text(
                                  'Masuk sebagai Admin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Hanya untuk admin Hagati yang terotorisasi',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFFd4af37),
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: const Color(0xFFd4af37), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1C1008),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFd4af37).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd4af37)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
