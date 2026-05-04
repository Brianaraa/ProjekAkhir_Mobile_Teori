import 'dart:convert';
import 'package:crypto/crypto.dart';    
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final database = Supabase.instance.client.from('users');

  String _hashPassword(String password) {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return '${digest.toString()}:$salt'; 
  }

  bool _verifyPassword(String enteredPassword, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final hash = parts[0];
      final salt = parts[1];

      final bytes = utf8.encode(enteredPassword + salt);
      final digest = sha256.convert(bytes);

      return hash == digest.toString();
    } catch (e) {
      print('Verify password error: $e');
      return false;
    }
  }

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

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final userResponse = await database
          .select()
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) return null;

      final storedHash = userResponse['password'] as String;
      final isValid = _verifyPassword(password, storedHash);

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

  Future<Map<String, dynamic>?> register(String nama, String email, String password) async {
    try {
      final isAvailable = await isEmailAvailable(email);
      if (!isAvailable) {
        print('Email sudah terdaftar');
        return null;
      }

      final hashedPassword = _hashPassword(password);

      final insertResponse = await database.insert({
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

  Future<bool> updateUser({required String userId, required String nama, required String email, String? password,}) async {
    try {
      final existingUser = await Supabase.instance.client
          .from('users')
          .select('uuid, email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null && existingUser['uuid'] != userId) {
        print('Email sudah digunakan oleh user lain');
        return false;
      }

      final data = {
        'nama': nama,
        'email': email,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = _hashPassword(password);
      }

      final response = await Supabase.instance.client
          .from('users')
          .update(data)
          .eq('uuid', userId)
          .select();

      if (response.isEmpty) {
        print('Update gagal: user dengan uuid $userId tidak ditemukan');
        return false;
      }

      print('Profil berhasil diupdate');
      return true;

    } catch (e) {
      print('UpdateUser Error: $e');
      return false;
    }
  }

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

  static Future<String?> getUserNameByUuid(String uuid) async {
    try {
      final data = await getUserByUuid(uuid);
      return data?['nama'] as String?;
    } catch (e) {
      print('Error getUserNameByUuid: $e');
      return null;
    }
  }

  static Future<void> saveCurrentUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_name', name);
  }

  static Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_name');
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id'); // ✅ FIX
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_name');
  }
}