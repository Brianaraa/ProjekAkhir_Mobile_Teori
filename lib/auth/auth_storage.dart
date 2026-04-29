import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _expiredAtKey = 'auth_expired_at';

  /// Simpan token + waktu expired (24 jam)
  static Future<void> saveSession({
    required String token,
    required DateTime expiredAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_expiredAtKey, expiredAt.toIso8601String());
  }

  /// Cek apakah session masih valid (token ada + belum expired)
  static Future<bool> isSessionValid() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiredStr = prefs.getString(_expiredAtKey);

    if (token == null || expiredStr == null) return false;

    final expiredAt = DateTime.parse(expiredStr);
    final now = DateTime.now();

    // Jika sekarang jam 13.00 dan expired jam 15.00, maka True (masih valid)
    return now.isBefore(expiredAt); 
  } catch (e) {
    print('Kesalahan baca session: $e'); // Tambahkan ini untuk cek error
    return false;
  }
}

  /// Hapus session (logout)
  static Future<void> deleteSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiredAtKey);
    print('🗑️ [SESSION] Token & expired dihapus');
  }

  /// Opsional: ambil token saja
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}