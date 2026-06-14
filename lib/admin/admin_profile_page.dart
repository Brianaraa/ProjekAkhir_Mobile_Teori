import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/admin_auth_service.dart';
import 'package:projek_akhir/auth/admin_auth_gate.dart';
import 'package:projek_akhir/models/admin_model.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _authService = AdminAuthService();
  AdminModel? _admin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final admin = await _authService.getCurrentAdmin();
    if (mounted) setState(() { _admin = admin; _isLoading = false; });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminAuthGate()),
        (r) => false,
      );
    }
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C1810),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ganti Password',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFd4af37), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(oldCtrl, 'Password Lama', isPassword: true),
              const SizedBox(height: 12),
              _dialogField(newCtrl, 'Password Baru', isPassword: true),
              const SizedBox(height: 12),
              _dialogField(confCtrl, 'Konfirmasi Password Baru', isPassword: true),
            ],
          ),
          actions: [
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFd4af37)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal',
                      style: TextStyle(color: Color(0xFFd4af37))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (newCtrl.text != confCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password tidak cocok'),
                            backgroundColor: Colors.red));
                      return;
                    }
                    setDialog(() => isSaving = true);
                    final ok = await _authService.changePassword(
                      _admin!.uuid,
                      oldCtrl.text,
                      newCtrl.text,
                    );
                    setDialog(() => isSaving = false);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? 'Password berhasil diubah' : 'Password lama salah'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af37),
                    foregroundColor: const Color(0xFF1C1008),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(strokeWidth: 2,
                          color: Color(0xFF1C1008))
                      : const Text('Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ],
        );
      }),
    );
  }

  void _showCreateAdminDialog() {
    final namaCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C1810),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Buat Admin Baru',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFd4af37), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(namaCtrl, 'Nama Admin'),
              const SizedBox(height: 12),
              _dialogField(emailCtrl, 'Email',
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _dialogField(passCtrl, 'Password', isPassword: true),
            ],
          ),
          actions: [
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFd4af37)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal',
                      style: TextStyle(color: Color(0xFFd4af37))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setDialog(() => isSaving = true);
                    final ok = await _authService.createAdmin(
                        namaCtrl.text, emailCtrl.text, passCtrl.text);
                    setDialog(() => isSaving = false);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? 'Admin baru berhasil dibuat'
                          : 'Gagal — email sudah terdaftar'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af37),
                    foregroundColor: const Color(0xFF1C1008),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(strokeWidth: 2,
                          color: Color(0xFF1C1008))
                      : const Text('Buat Admin',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1008),
      appBar: AppBar(title: const Text('Profil Admin')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFd4af37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFd4af37),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFd4af37).withOpacity(0.3),
                          width: 3),
                    ),
                    child: const Icon(Icons.admin_panel_settings,
                        color: Color(0xFF1C1008), size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _admin?.nama ?? 'Admin',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _admin?.email ?? '',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd4af37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Super Admin',
                        style: TextStyle(
                            color: Color(0xFFd4af37),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 40),

                  _menuTile(
                    icon: Icons.lock_outline,
                    title: 'Ganti Password',
                    onTap: _showChangePasswordDialog,
                  ),
                  const SizedBox(height: 10),
                  _menuTile(
                    icon: Icons.person_add_outlined,
                    title: 'Buat Admin Baru',
                    onTap: _showCreateAdminDialog,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.15),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Hagati Admin v1.0.0',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.2), fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C1810),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFd4af37).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFd4af37), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label, {
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Color(0xFFd4af37), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1C1008),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFd4af37).withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFd4af37)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
