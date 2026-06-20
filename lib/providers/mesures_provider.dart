import 'package:flutter/material.dart';
import '../models/mesure_glycemie.dart';
import '../services/storage_service.dart';
import '../services/fhir_service.dart';
import '../services/sync_service.dart';

class MesuresProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final FhirService _fhir = FhirService();
  late final SyncService _sync;

  List<MesureGlycemie> _mesures = [];
  bool _chargement = false;
  String? _erreur;
  int _nonSynchronisees = 0;

  List<MesureGlycemie> get mesures => _mesures;
  bool get chargement => _chargement;
  String? get erreur => _erreur;
  int get nonSynchronisees => _nonSynchronisees;

  MesureGlycemie? get derniere =>
      _mesures.isNotEmpty ? _mesures.first : null;

  double get moyenne {
    if (_mesures.isEmpty) return 0;
    final total = _mesures.map((m) => m.valeur).reduce((a, b) => a + b);
    return total / _mesures.length;
  }

  List<MesureGlycemie> get alertesCritiques =>
      _mesures.where((m) => m.estCritique).toList();

  List<MesureGlycemie> get alertesOrange =>
      _mesures.where((m) => m.estAlerteOrange).toList();

  MesuresProvider() {
    _sync = SyncService(_storage, _fhir);
  }

  Future<void> charger() async {
    _chargement = true;
    notifyListeners();
    _mesures = _storage.toutesLesMesures();
    _nonSynchronisees = _storage.mesuresNonSynchronisees().length;
    _chargement = false;
    notifyListeners();
  }

  Future<void> ajouter(MesureGlycemie mesure) async {
    await _storage.sauvegarder(mesure);
    await charger();
    _syncEnArrierePlan();
  }

  Future<void> supprimer(MesureGlycemie mesure) async {
    await _storage.supprimer(mesure);
    await charger();
  }

  Future<void> synchroniser() async {
    final count = await _sync.synchroniser();
    if (count > 0) await charger();
  }

  bool _recuperationFhir = false;
  bool get recuperationFhir => _recuperationFhir;
  String? _messageFhir;
  String? get messageFhir => _messageFhir;

  Future<void> recupererDepuisFhir() async {
    _recuperationFhir = true;
    _messageFhir = null;
    notifyListeners();

    try {
      final observations = await _fhir.recupererObservations();
      _messageFhir = '${observations.length} observation(s) trouvée(s) sur le serveur FHIR';
    } catch (_) {
      _messageFhir = 'Erreur lors de la récupération FHIR';
    }

    _recuperationFhir = false;
    notifyListeners();
  }

  void _syncEnArrierePlan() async {
    await Future.delayed(const Duration(seconds: 2));
    await synchroniser();
  }
}