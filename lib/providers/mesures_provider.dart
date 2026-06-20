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

  bool _verificationFhir = false;
  bool get verificationFhir => _verificationFhir;
  String? _messageFhir;
  String? get messageFhir => _messageFhir;
  bool? _derniereVerificationOk;
  bool? get derniereVerificationOk => _derniereVerificationOk;

  /// Vérifie qu'une mesure synchronisée existe bien côté serveur FHIR
  Future<void> verifierIntegriteSync() async {
    _verificationFhir = true;
    _messageFhir = null;
    notifyListeners();

    final mesuresSync = _mesures.where((m) => m.estSynchronisee && m.idFhir != null).toList();

    if (mesuresSync.isEmpty) {
      _messageFhir = 'Aucune mesure synchronisée à vérifier pour le moment.';
      _verificationFhir = false;
      _derniereVerificationOk = null;
      notifyListeners();
      return;
    }

    final derniere = mesuresSync.first;
    final observationDistante = await _fhir.recupererObservationParId(derniere.idFhir!);

    if (observationDistante != null) {
      final coherent = (observationDistante.valeur - derniere.valeur).abs() < 0.01;
      _derniereVerificationOk = coherent;
      _messageFhir = coherent
          ? 'Intégrité confirmée : la dernière mesure (${derniere.valeurFormatee}) correspond bien au serveur FHIR.'
          : 'Incohérence détectée entre les données locales et le serveur FHIR.';
    } else {
      _derniereVerificationOk = false;
      _messageFhir = 'Impossible de retrouver cette mesure sur le serveur FHIR.';
    }

    _verificationFhir = false;
    notifyListeners();
  }

  void _syncEnArrierePlan() async {
    await Future.delayed(const Duration(seconds: 2));
    await synchroniser();
  }
}