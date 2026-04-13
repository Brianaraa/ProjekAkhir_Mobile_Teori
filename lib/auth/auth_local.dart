import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // cek apakah device support biometric
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics;
      bool isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      print('Error check biometric: $e');
      return false;
    }
  }

  // proses autentikasi
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan fingerprint untuk masuk',
        biometricOnly: true,
      );
    } catch (e) {
      print('Biometric error: $e');
      return false;
    }
  }
}