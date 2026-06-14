import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_akhir/models/admin_model.dart';

class AdminAuthService {
  static const _keyAdminId    = 'admin_id';
  static const _keyAdminNama  = 'admin_nama';
  static const _keyAdminEmail = 'admin_email';
  static const _keyToken      = 'admin_token';
  static const _keyExpiredAt  = 'admin_expired_at';

  final _db = Supabase.instance.client.from('admin');

  // Hash SHA256 + salt (sama persis dengan user_service.dart di app utama)
  String _hashPassword(String password) {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return '${digest.toString()}:$salt';
  }

  bool _verifyPassword(String entered, String stored) {
    try {
      final parts = stored.split(':');
      if (parts.length != 2) {
        print('DEBUG LOGIN: Format password di DB salah (tidak mengandung salt)');
        return false;
      }
      final hash = parts[0];
      final salt = parts[1];
      final bytes = utf8.encode(entered + salt);
      final digest = sha256.convert(bytes);
      print('DEBUG LOGIN: entered: $entered, salt: $salt');
      print('DEBUG LOGIN: Hasil hash entered+salt: ${digest.toString()}');
      print('DEBUG LOGIN: Bandingkan dengan hash DB: $hash');
      return hash == digest.toString();
    } catch (e) {
      print('DEBUG LOGIN: Error saat verifikasi password: $e');
      return false;
    }
  }

  Future<AdminModel?> login(String email, String password) async {
    try {
      print('DEBUG LOGIN: Memulai login untuk email: $email');
      final res = await _db
          .select()
          .eq('email', email)
          .maybeSingle();
      
      print('DEBUG LOGIN: Hasil query database: $res');
      if (res == null) {
        print('DEBUG LOGIN: User tidak ditemukan di database');
        return null;
      }

      final storedPassword = res['password'] as String;
      print('DEBUG LOGIN: Password tersimpan di DB: $storedPassword');
      
      final isValid = _verifyPassword(password, storedPassword);
      print('DEBUG LOGIN: Hasil verifikasi password: $isValid');
      
      if (!isValid) return null;

      final admin = AdminModel.fromJson(res);

      // Simpan session
      final prefs = await SharedPreferences.getInstance();
      final token = 'admin_${DateTime.now().millisecondsSinceEpoch}';
      final expiredAt = DateTime.now().add(const Duration(hours: 8));
      await prefs.setString(_keyAdminId, admin.uuid);
      await prefs.setString(_keyAdminNama, admin.nama);
      await prefs.setString(_keyAdminEmail, admin.email);
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyExpiredAt, expiredAt.toIso8601String());

      return admin;
    } catch (e) {
      print('AdminAuthService.login error: $e');
      return null;
    }
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final expStr = prefs.getString(_keyExpiredAt);
    if (token == null || expStr == null) return false;
    final exp = DateTime.tryParse(expStr);
    if (exp == null) return false;
    return DateTime.now().isBefore(exp);
  }

  Future<AdminModel?> getCurrentAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final id    = prefs.getString(_keyAdminId);
    final nama  = prefs.getString(_keyAdminNama);
    final email = prefs.getString(_keyAdminEmail);
    if (id == null) return null;
    return AdminModel(
      uuid: id,
      nama: nama ?? '',
      email: email ?? '',
      createdAt: DateTime.now(),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAdminId);
    await prefs.remove(_keyAdminNama);
    await prefs.remove(_keyAdminEmail);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyExpiredAt);
  }

  // Registrasi admin baru (hanya bisa dilakukan oleh admin yang sudah login)
  Future<bool> createAdmin(String nama, String email, String password) async {
    try {
      final existing = await _db
          .select('uuid')
          .eq('email', email)
          .maybeSingle();
      if (existing != null) return false;

      final hashed = _hashPassword(password);
      await _db.insert({
        'nama': nama,
        'email': email,
        'password': hashed,
      });
      return true;
    } catch (e) {
      print('createAdmin error: $e');
      return false;
    }
  }

  Future<bool> changePassword(
      String adminId, String oldPassword, String newPassword) async {
    try {
      final res = await _db
          .select('password')
          .eq('uuid', adminId)
          .single();
      if (!_verifyPassword(oldPassword, res['password'])) return false;
      final newHash = _hashPassword(newPassword);
      await _db.update({'password': newHash}).eq('uuid', adminId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
