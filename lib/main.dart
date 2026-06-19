import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/mesure_glycemie.dart';
import 'providers/mesures_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MesureGlycemieAdapter());
  await Hive.openBox<MesureGlycemie>('mesures');

  runApp(
    ChangeNotifierProvider(
      create: (_) => MesuresProvider()..charger(),
      child: const GlycoTrackApp(),
    ),
  );
}