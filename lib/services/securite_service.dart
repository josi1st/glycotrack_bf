/// Service de sécurité pour protéger la vie privée de l'utilisateur
///
/// Gère:
/// - Activation du masquage de contenu sensible en multitâche
/// - Empeche les captures d'écran des données sensibles
/// - Masque le contenu quand l'app passe en arrière-plan

import 'package:flutter/services.dart';

/// Service pour les paramètres de sécurité natives
class SecuriteService {
  /// Canal de communication avec le code natif (Kotlin/Android)
  static const _channel = MethodChannel('glycotrack_bf/securite');

  /// Active le masquage sécurisé du contenu
  ///
  /// Empeche:
  /// - Les captures d'écran
  /// - L'affichage en apercu multitâche
  /// - La visualisation du contenu sensible à l'écran de verrouillage
  ///
  /// Fonctionne sur Android native uniquement
  /// (Les erreurs sur autres plateformes sont ignorées silencieusement)
  static Future<void> activerMasquage() async {
    try {
      await _channel.invokeMethod('activerFlagSecure');
    } catch (_) {
      // Plateforme non supportée (web/desktop) — ignoré silencieusement
    }
  }
}
