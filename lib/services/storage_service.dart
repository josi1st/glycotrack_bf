/// Service pour gérer la persistance locale des mesures
///
/// Utilise Hive pour le stockage chiffré et offre des opérations CRUD
/// ainsi que des requêtes spécialisées (filtrage, synchronisation).

import 'package:hive_flutter/hive_flutter.dart';
import '../models/mesure_glycemie.dart';

/// Service singleton pour l'accès à la base de données Hive
class StorageService {
  static const String _boxName = 'mesures';

  /// Accès à la boîte Hive contenant les mesures
  Box<MesureGlycemie> get _box => Hive.box<MesureGlycemie>(_boxName);

  /// Sauvegarde une nouvelle mesure en base de données
  Future<void> sauvegarder(MesureGlycemie mesure) async {
    await _box.add(mesure);
  }

  /// Récupère toutes les mesures triées par date décroissante (plus récente en premier)
  List<MesureGlycemie> toutesLesMesures() {
    final mesures = _box.values.toList();
    mesures.sort((a, b) => b.date.compareTo(a.date));
    return mesures;
  }

  /// Retourne les mesures non encore synchronisées au serveur FHIR
  List<MesureGlycemie> mesuresNonSynchronisees() {
    return _box.values.where((m) => !m.estSynchronisee).toList();
  }

  /// Marque une mesure comme synchronisée
  Future<void> marquerSynchronisee(MesureGlycemie mesure) async {
    mesure.estSynchronisee = true;
    await mesure.save();
  }

  /// Enregistre l'identifiant FHIR d'une mesure synchronisée
  Future<void> enregistrerIdFhir(MesureGlycemie mesure, String idFhir) async {
    mesure.idFhir = idFhir;
    await mesure.save();
  }

  /// Supprime une mesure
  Future<void> supprimer(MesureGlycemie mesure) async {
    await mesure.delete();
  }

  /// Vide complètement la base de données (toutes les mesures)
  Future<void> toutSupprimer() async {
    await _box.clear();
  }
}
