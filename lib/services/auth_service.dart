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


  Future<void> supprimerProfilComplet() async {
    await _storage.delete(key: 'user_nom');
    await _storage.delete(key: 'user_telephone');
    await _storage.delete(key: 'consentement_rgpd');
  }

  
  Future<bool> biometrieDisponible() async {
    try {
      final supporte = await _auth.isDeviceSupported();
      final peutVerifier = await _auth.canCheckBiometrics;
      return supporte && peutVerifier;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authentifierBiometrie() async {
    try {
      final disponible = await biometrieDisponible();
      if (!disponible) return false;

      return await _auth.authenticate(
        localizedReason: 'Identifiez-vous pour accéder à vos données de santé',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> sauvegarderProfil({required String nom, required String telephone}) async {
    await _storage.write(key: 'user_nom', value: nom);
    await _storage.write(key: 'user_telephone', value: telephone);
  }

  Future<String?> lireNom() async {
    return await _storage.read(key: 'user_nom');
  }

  Future<String?> lireTelephone() async {
    return await _storage.read(key: 'user_telephone');
  }

  Future<bool> profilExiste() async {
    final nom = await lireNom();
    return nom != null;
  }
}