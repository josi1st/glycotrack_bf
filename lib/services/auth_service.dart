/// Service d'authentification et gestion du profil utilisateur
///
/// Gère:
/// - Authentification biométrique (empreinte, visage, PIN)
/// - Stockage sécurisé du profil utilisateur (nom, téléphone)
/// - Consentement RGPD
/// - Suppression complète des données

import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service singleton pour l'authentification et le profil
class AuthService {
  /// Instance pour l'authentification biométrique locale
  final LocalAuthentication _auth = LocalAuthentication();

  /// Instance pour le stockage sécurisé
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Vérifie si c'est le premier lancement (consentement RGPD non enregistré)
  Future<bool> estPremierLancement() async {
    final valeur = await _storage.read(key: 'consentement_rgpd');
    return valeur == null;
  }

  /// Enregistre l'acceptation du consentement RGPD
  Future<void> enregistrerConsentement() async {
    await _storage.write(
      key: 'consentement_rgpd',
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Supprime complètement le profil et les données de consentement
  Future<void> supprimerProfilComplet() async {
    await _storage.delete(key: 'user_nom');
    await _storage.delete(key: 'user_telephone');
    await _storage.delete(key: 'consentement_rgpd');
  }

  /// Vérifie que le dispositif supporte et peut utiliser la biométrie
  ///
  /// Retourne true si:
  /// - Le dispositif supporte la biométrie
  /// - Au moins une biométrie est enregistrée
  Future<bool> biometrieDisponible() async {
    try {
      final supporte = await _auth.isDeviceSupported();
      final peutVerifier = await _auth.canCheckBiometrics;
      return supporte && peutVerifier;
    } catch (_) {
      return false;
    }
  }

  /// Authentifie l'utilisateur par biométrie
  ///
  /// Affiche un dialog natif pour l'authentification biométrique
  /// Retourne true si l'authentification réussit
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

  /// Sauvegarde le profil utilisateur de manière sécurisée
  Future<void> sauvegarderProfil(
      {required String nom, required String telephone}) async {
    await _storage.write(key: 'user_nom', value: nom);
    await _storage.write(key: 'user_telephone', value: telephone);
  }

  /// Récupère le nom de l'utilisateur sauvegardé
  Future<String?> lireNom() async {
    return await _storage.read(key: 'user_nom');
  }

  /// Récupère le téléphone de l'utilisateur sauvegardé
  Future<String?> lireTelephone() async {
    return await _storage.read(key: 'user_telephone');
  }

  /// Vérifie si un profil utilisateur existe
  Future<bool> profilExiste() async {
    final nom = await lireNom();
    return nom != null;
  }
}
