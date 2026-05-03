import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_akhir/auth/auth_gate.dart';
import 'package:projek_akhir/auth/auth_storage.dart';
import 'package:projek_akhir/pages/bookmark_page.dart';
import 'package:projek_akhir/pages/kesan_pesan.dart';
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

      final imageUrlWithCacheBuster = '$url?t=$timestamp';

      setState(() {
        _profileImageUrl = imageUrlWithCacheBuster;
      });
    } catch (e) {
      print('Error loading profile image: $e');
      setState(() => _profileImageUrl = null);
    }
  }

  Future<void> _uploadProfilePhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFd4af37)),
                title: const Text('Ambil dari Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Color(0xFFd4af37)),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? pickedFile = await picker.pickImage(
      source: source,
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
            content: Text('Gagal upload: ${e.toString()}'),
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

  //buat edit
  void _showEditDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xfffcf9f8),
        title: const Text(
          'Edit Profil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF884513),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Perbarui informasi akun Anda di bawah ini",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              _buildEditTextField(
                controller: nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),
              _buildEditTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),
              _buildEditTextField(
                controller: passwordController,
                label: 'Password Baru (Opsional)',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),

        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Color(0xFF884513)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: Color(0xFF884513), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 12),
  
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
                        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal update profil'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af37),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Color(0xFF884513), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk TextField Edit Profil agar tidak duplikasi kode
  Widget _buildEditTextField({ required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, 
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon, color: const Color(0xFFd4af37), size: 20),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFd4af37), width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _goToKesanPesanPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KesanPesanPage(),
      ),
    );
  }

  void _goToBookmarkPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookmarkPage(),
      ),
    );
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

              // upload foto
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

                  // edit foto
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

              Text(
                _userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                _userEmail,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // ini button edit ptofilr
              _buildMenuCard(
                icon: Icons.person,
                iconColor: Color(0xFFd4af37),
                iconBgColor: Color(0xFFd4af37),
                title: "Edit Profile",
                onTap: _showEditDialog,
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.feedback_outlined,
                iconColor: Color(0xFFd4af37),
                iconBgColor: const Color(0xFFd4af37).withOpacity(0.15),
                title: "Saran & Kesan TPM",
                onTap: _goToKesanPesanPage,
              ),

              const SizedBox(height: 12),

              // menu notif
              _buildMenuCard(
                icon: Icons.bookmark,
                iconColor: Color(0xFFd4af37),
                iconBgColor: const Color(0xFFd4af37).withOpacity(0.15),
                title: "Bookmark",
                onTap: _goToBookmarkPage,
              ),

              const SizedBox(height: 40),

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

  Widget _buildMenuCard({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required VoidCallback onTap,}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

}