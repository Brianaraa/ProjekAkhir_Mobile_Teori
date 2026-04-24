import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_service.dart';
import 'package:projek_akhir/auth/auth_gate.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  final _kesanController = TextEditingController();
  final _saranController = TextEditingController();
  int _rating = 0;
  bool _submitted = false;

  void _logout() async {
    try {
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

  void _submitFeedback() {
    if (_kesanController.text.isEmpty || _saranController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kesan dan saran tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback berhasil dikirim!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = authService.getCurrentUserName() ?? 'User';
    final email = authService.getCurrentUserEmail() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil',
                style:
                    TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Avatar + info
              _profileHeader(name, email),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),

              // Form saran & kesan TPM
              const Text(
                'Saran & Kesan TPM',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Teknologi & Pemrograman Mobile',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              _feedbackForm(),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Logout
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(String name, String email) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: const Color(0xFFd4af37),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(email,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _feedbackForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xfff6f3f2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating bintang
          const Text('Rating Mata Kuliah',
              style:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: _submitted ? null : () => setState(() => _rating = i + 1),
                child: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFd4af37),
                  size: 32,
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Kesan
          const Text('Kesan selama mengikuti mata kuliah ini',
              style:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _multilineField(_kesanController, 'Tuliskan kesan kamu...'),

          const SizedBox(height: 20),

          // Saran
          const Text('Saran untuk pengembangan mata kuliah',
              style:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _multilineField(_saranController, 'Tuliskan saran kamu...'),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submitted ? null : _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: _submitted ? Colors.grey : const Color(0xFFd4af37),
              foregroundColor: const Color(0xFF884513),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            child: Text(
              _submitted ? 'Feedback Terkirim ✓' : 'Kirim Feedback',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _multilineField(
      TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 4,
      enabled: !_submitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFd4af37), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _kesanController.dispose();
    _saranController.dispose();
    super.dispose();
  }
}