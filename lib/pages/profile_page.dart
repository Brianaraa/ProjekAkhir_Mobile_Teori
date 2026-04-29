import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_akhir/auth/auth_gate.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'User';
  String _userEmail = '';
  String? _profileImageUrl;
  bool _isUploading = false;

  // Controller untuk feedback
  final _kesanController = TextEditingController();
  final _saranController = TextEditingController();
  int _rating = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('user_id');

    setState(() {
      _userName = prefs.getString('nama') ?? 'User';
      _userEmail = prefs.getString('email') ?? '';
    });

    if (uuid != null) {
      _loadProfileImage(uuid);
    }
  }

  void _loadProfileImage(String uuid) {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Supabase.instance.client.storage
        .from('profile')
        .getPublicUrl('$uuid.jpg');

    // Tambahkan timestamp agar cache di-refresh
    final imageUrlWithCacheBuster = '$url?t=$timestamp';

    setState(() {
      _profileImageUrl = imageUrlWithCacheBuster;
    });
  } catch (e) {
    print('Error loading profile image: $e');
    setState(() => _profileImageUrl = null);
  }
}

  // ================== UPLOAD FOTO PROFIL ==================
Future<void> _uploadProfilePhoto() async {
  final picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 75,
    maxWidth: 800,
  );

  if (pickedFile == null) return;

  setState(() => _isUploading = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final String? uuid = prefs.getString('user_id');

    if (uuid == null || uuid.isEmpty) {
      throw Exception('User ID tidak ditemukan');
    }

    final bytes = await pickedFile.readAsBytes();
    final fileName = '$uuid.jpg';

    await Supabase.instance.client.storage
        .from('profile')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    // Refresh gambar dengan cache buster
    _loadProfileImage(uuid);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print('Upload Error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupload foto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isUploading = false);
    }
  }
}

  // ================== LOGOUT ==================
  void _logout() async {
    await AuthStorage.deleteSession();
    await UserService.logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    }
  }

  // ================== DIALOG EDIT PROFILE (Tanpa Foto) ==================
  void _showEditDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFd4af37),
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password Baru (opsional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString('user_id');

                          if (userId == null || userId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User ID tidak ditemukan'), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          final success = await UserService().updateUser(
                            userId: userId,
                            nama: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim().isEmpty
                                ? null
                                : passwordController.text.trim(),
                          );

                          if (success) {
                            await prefs.setString('nama', nameController.text.trim());
                            await prefs.setString('email', emailController.text.trim());

                            setState(() {
                              _userName = nameController.text.trim();
                              _userEmail = emailController.text.trim();
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil berhasil diperbarui'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal update profil'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd4af37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  // ================== DIALOG SARAN & KESAN ==================
  void _showFeedbackDialog() {
    // Reset nilai saat dialog dibuka
    _rating = 0;
    _kesanController.clear();
    _saranController.clear();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saran & Kesan TPM',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFd4af37),
                  ),
                ),
                const SizedBox(height: 24),

                // Rating
                const Text(
                  'Rating Mata Kuliah',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _rating = i + 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFd4af37),
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Kesan
                const Text(
                  'Kesan',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _kesanController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan kesan kamu terhadap mata kuliah...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 20),

                // Saran
                const Text(
                  'Saran',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _saranController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan saran untuk perbaikan...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 28),

                // Tombol
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd4af37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Kirim Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  void _submitFeedback() {
    if (_kesanController.text.trim().isEmpty || _saranController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kesan dan saran tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _submitted = true);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback berhasil dikirim! Terima kasih.'),
        backgroundColor: Colors.green,
      ),
    );

    _kesanController.clear();
    _saranController.clear();
    _rating = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ================== AVATAR + TOMBOL UPLOAD ==================
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFFd4af37),
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),

                  // Tombol Ubah Foto
                  GestureDetector(
                    onTap: _isUploading ? null : _uploadProfilePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd4af37),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Nama & Email
              Text(
                _userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                _userEmail,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Statistik
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Row(
                    children: [
                      _buildStat("3", "Hajatan"),
                      _buildStat("12", "Vendor"),
                      _buildStat("5", "Checklist"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Menu Edit Profile
              _buildMenuCard(
                icon: Icons.person,
                iconColor: Colors.brown,
                iconBgColor: const Color(0xFFFFE082),
                title: "Edit Profile",
                onTap: _showEditDialog,
              ),

              const SizedBox(height: 12),

              // Menu Saran & Kesan
              _buildMenuCard(
                icon: Icons.feedback_outlined,
                iconColor: const Color(0xFFd4af37),
                iconBgColor: const Color(0xFFd4af37).withOpacity(0.15),
                title: "Saran & Kesan TPM",
                onTap: _showFeedbackDialog,
              ),

              const SizedBox(height: 40),

              // Logout Button
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Keluar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
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