import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'models/mesure_glycemie.dart';
import 'providers/mesures_provider.dart';
import 'app.dart';
import 'services/securite_service.dart';
import 'services/notification_service.dart';

const _storage = FlutterSecureStorage();

Future<List<int>> _obtenirCleChiffrement() async {
  const cleStockage = 'hive_encryption_key';
  String? cleExistante = await _storage.read(key: cleStockage);

  if (cleExistante == null) {
    final cle = Hive.generateSecureKey();
    await _storage.write(key: cleStockage, value: base64UrlEncode(cle));
    return cle;
  }

  return base64Url.decode(cleExistante);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecuriteService.activerMasquage();
  await NotificationService().initialiser();

  await Hive.initFlutter();
  Hive.registerAdapter(MesureGlycemieAdapter());

  final cleChiffrement = await _obtenirCleChiffrement();

  await Hive.openBox<MesureGlycemie>(
    'mesures',
    encryptionCipher: HiveAesCipher(cleChiffrement),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => MesuresProvider()..charger(),
      child: const GlycoTrackApp(),
    ),
  );
}