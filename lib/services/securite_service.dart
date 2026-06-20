import 'package:flutter/services.dart';

class SecuriteService {
  static const _channel = MethodChannel('glycotrack_bf/securite');

  static Future<void> activerMasquage() async {
    try {
      await _channel.invokeMethod('activerFlagSecure');
    } catch (_) {
      // Plateforme non supportée (web/desktop) — ignoré silencieusement
    }
  }
}