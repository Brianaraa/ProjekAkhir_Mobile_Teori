import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan fingerprint untuk masuk',
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }
}