import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      if (kIsWeb) return true; // Bypass jika dijalankan di Web (Chrome/Edge)
      
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return true; // Bypass jika device/emulator tidak punya fingerprint

      return await _auth.authenticate(
        localizedReason: 'Scan fingerprint untuk masuk',
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }
}