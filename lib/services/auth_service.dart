import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> estPremierLancement() async {
    final valeur = await _storage.read(key: 'consentement_rgpd');
    return valeur == null;
  }

  Future<void> enregistrerConsentement() async {
    await _storage.write(
      key: 'consentement_rgpd',
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<bool> biometrieDisponible() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authentifierBiometrie() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Identifiez-vous pour accéder à vos données de santé',
        options: const AuthenticationOptions(biometricOnly: false),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> sauvegarderEmail(String email) async {
    await _storage.write(key: 'user_email', value: email);
  }

  Future<String?> lireEmail() async {
    return await _storage.read(key: 'user_email');
  }
}