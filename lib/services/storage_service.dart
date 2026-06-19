import 'package:hive_flutter/hive_flutter.dart';
import '../models/mesure_glycemie.dart';

class StorageService {
  static const String _boxName = 'mesures';

  Box<MesureGlycemie> get _box => Hive.box<MesureGlycemie>(_boxName);

  Future<void> sauvegarder(MesureGlycemie mesure) async {
    await _box.add(mesure);
  }

  List<MesureGlycemie> toutesLesMesures() {
    final mesures = _box.values.toList();
    mesures.sort((a, b) => b.date.compareTo(a.date));
    return mesures;
  }

  List<MesureGlycemie> mesuresNonSynchronisees() {
    return _box.values.where((m) => !m.estSynchronisee).toList();
  }

  Future<void> marquerSynchronisee(MesureGlycemie mesure) async {
    mesure.estSynchronisee = true;
    await mesure.save();
  }

  Future<void> supprimer(MesureGlycemie mesure) async {
    await mesure.delete();
  }

  Future<void> toutSupprimer() async {
    await _box.clear();
  }
}