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

  /// Vérifie si la biométrie est disponible ET configurée sur l'appareil
  Future<bool> biometrieDisponible() async {
    try {
      final supporte = await _auth.isDeviceSupported();
      final peutVerifier = await _auth.canCheckBiometrics;
      return supporte && peutVerifier;
    } catch (_) {
      return false;
    }
  }

  /// Authentification réelle — c'est la SEULE porte d'entrée vers l'app
  Future<bool> authentifierBiometrie() async {
    try {
      final disponible = await biometrieDisponible();
      if (!disponible) return false;

      return await _auth.authenticate(
        localizedReason: 'Identifiez-vous pour accéder à vos données de santé',
        options: const AuthenticationOptions(
          biometricOnly: false, // autorise aussi le code PIN/schéma du téléphone en secours
          stickyAuth: true,
        ),
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

  Future<bool> profilExiste() async {
    final email = await lireEmail();
    return email != null;
  }
}