import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _expiredAtKey = 'auth_expired_at';
  static const _biometricKey = 'biometric_enabled';

  //simpen session
  static Future<void> saveSession({
    required String token,
    required DateTime expiredAt,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _expiredAtKey,
      value: expiredAt.toIso8601String(),
    );
  }

  ///cek session valid
  static Future<bool> isSessionValid() async {
    final token = await _storage.read(key: _tokenKey);
    final expiredStr = await _storage.read(key: _expiredAtKey);

    if (token == null || expiredStr == null) return false;

    final expiredAt = DateTime.parse(expiredStr);
    return DateTime.now().isBefore(expiredAt);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // logout
  static Future<void> deleteSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiredAtKey);
  }
  
  static Future<void> setBiometric(bool value) async {
    await _storage.write(key: _biometricKey, value: value.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricKey);
    return value == 'true';
  }
}