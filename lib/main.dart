/// Point d'entrée principal de l'application GlycoTrack BF
///
/// Cette classe gère:
/// - L'initialisation de la base de données locale (Hive)
/// - L'initialisation du chiffrement des données
/// - Le setup des services de sécurité et de notifications
/// - L'initialisation du Provider pour la gestion d'état

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'models/mesure_glycemie.dart';
import 'providers/mesures_provider.dart';
import 'app.dart';
import 'services/securite_service.dart';
import 'services/notification_service.dart';

/// Instance globale pour accéder au stockage sécurisé
const _storage = FlutterSecureStorage();

/// Génère ou récupère la clé de chiffrement pour Hive
///
/// Si aucune clé n'existe, en génère une nouvelle et la stocke de manière sécurisée.
/// À chaque lancement, récupère la clé précédemment stockée pour maintenir la cohérence.
Future<List<int>> _obtenirCleChiffrement() async {
  const cleStockage = 'hive_encryption_key';
  String? cleExistante = await _storage.read(key: cleStockage);

  // Si aucune clé n'existe, en générer une nouvelle
  if (cleExistante == null) {
    final cle = Hive.generateSecureKey();
    await _storage.write(key: cleStockage, value: base64UrlEncode(cle));
    return cle;
  }

  // Sinon, récupérer la clé existante
  return base64Url.decode(cleExistante);
}

/// Point d'entrée main() de l'application
///
/// Effectue l'initialisation complète:
/// 1. Binding Flutter pour l'accès aux APIs natives
/// 2. Activation de la sécurité (masquage du contenu en multitâche)
/// 3. Initialisation des notifications locales
/// 4. Configuration de Hive avec chiffrement AES
/// 5. Lancement de l'app avec Provider pour la gestion d'état
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Active le masquage de contenu en arrière-plan et en multitâche
  // await SecuriteService.activerMasquage();
  // Initialise le système de notifications locales
  await NotificationService().initialiser();

  // Initialise Hive pour Flutter
  await Hive.initFlutter();
  // Enregistre l'adaptateur pour le type MesureGlycemie
  Hive.registerAdapter(MesureGlycemieAdapter());

  // Récupère la clé de chiffrement
  final cleChiffrement = await _obtenirCleChiffrement();

  // Ouvre la boîte Hive avec chiffrement AES
  await Hive.openBox<MesureGlycemie>(
    'mesures',
    encryptionCipher: HiveAesCipher(cleChiffrement),
  );

  // Lance l'app avec Provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => MesuresProvider()..charger(),
      child: const GlycoTrackApp(),
    ),
  );
}
