import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final database = Supabase.instance.client.from('users');

  //Pengecekkan email
  Future<bool> isEmailAvailable(String email, {String? excludeUserId}) async {
    final query = Supabase.instance.client
        .from('users')
        .select('uuid')
        .eq('email', email);

    if (excludeUserId != null) {
      query.neq('uuid', excludeUserId);
    }

    final existing = await query.maybeSingle();
    return existing == null;
  }

  // LOGIN
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final userResponse = await database
          .select()
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) return null;

      bool isValid = BCrypt.checkpw(password, userResponse['password']);
      if (!isValid) return null;

      // Generate token sederhana
      final token = 'token_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'token': token,
        'user': userResponse,
      };
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // REGISTER
  Future<Map<String, dynamic>?> register(String nama, String email, String password) async {
    try {
      final isAvailable = await isEmailAvailable(email); // cek email ada atau ga
      if (!isAvailable) {
        print('Email sudah terdaftar');
        return null;
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      final insertResponse = await database.insert({ // kirim user baru
        'nama': nama,
        'email': email,
        'password': hashedPassword,
      }).select().single();

      return insertResponse;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  // UPDATE USER DENGAN PENGECEKAN EMAIL
Future<bool> updateUser({
  required String userId,
  required String nama,
  required String email,
  String? password,
}) async {
    try {
      // 1. Cek apakah email baru sudah dipakai oleh user LAIN
      final existingUser = await Supabase.instance.client
          .from('users')
          .select('uuid, email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null && existingUser['uuid'] != userId) {
        print('Email sudah digunakan oleh user lain: ${existingUser['uuid']}');
        return false; // Email sudah dipakai
      }

      // 2. Siapkan data yang akan diupdate
      final data = {
        'nama': nama,
        'email': email,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = BCrypt.hashpw(password, BCrypt.gensalt());
      }

      // 3. Lakukan update
      final response = await Supabase.instance.client
          .from('users')
          .update(data)
          .eq('uuid', userId)
          .select();

      if (response.isEmpty) {
        print('Update gagal: user dengan uuid $userId tidak ditemukan');
        return false;
      }

      print('✅ Profil berhasil diupdate. Email baru: $email');
      return true;

    } catch (e) {
      print('UpdateUser Error: $e');
      return false;
    }
  }

  // Ambil data user lengkap dari Supabase berdasarkan uuid
  static Future<Map<String, dynamic>?> getUserByUuid(String uuid) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('uuid', uuid)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getUserByUuid: $e');
      return null;
    }
  }

  // Ambil nama saja (untuk HomePage)
  static Future<String?> getUserNameByUuid(String uuid) async {
    try {
      final data = await getUserByUuid(uuid);
      return data?['nama'] as String?;
    } catch (e) {
      print('Error getUserNameByUuid: $e');
      return null;
    }
  }

  // Simpan nama user setelah login / register
  static Future<void> saveCurrentUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_name', name);
  }

  // Ambil nama user yang sedang login
  static Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_name');
  }

  // Logout (hapus nama user juga)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_name');
  }
}