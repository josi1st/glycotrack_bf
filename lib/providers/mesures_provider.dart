/// Provider pour la gestion d'état des mesures
///
/// Utilise ChangeNotifier pour notifier l'UI des changements.
/// Gère les opérations CRUD, la synchronisation FHIR et les alertes.

import 'package:flutter/material.dart';
import '../models/mesure_glycemie.dart';
import '../services/storage_service.dart';
import '../services/fhir_service.dart';
import '../services/sync_service.dart';

/// Provider global pour la gestion des mesures
///
/// Fournit:
/// - Les mesures locales (liste, dernière, statistiques)
/// - Le statut de synchronisation FHIR
/// - Les opérations CRUD
class MesuresProvider extends ChangeNotifier {
  /// Service de stockage local
  final StorageService _storage = StorageService();

  /// Service FHIR pour la synchronisation
  final FhirService _fhir = FhirService();

  /// Service de synchronisation
  late final SyncService _sync;

  /// Liste des mesures locales (triée, plus récente en premier)
  List<MesureGlycemie> _mesures = [];

  /// Flag d'état de chargement
  bool _chargement = false;

  /// Message d'erreur éventuel
  String? _erreur;

  /// Nombre de mesures non synchronisées
  int _nonSynchronisees = 0;

  // Getters publics
  List<MesureGlycemie> get mesures => _mesures;
  bool get chargement => _chargement;
  String? get erreur => _erreur;
  int get nonSynchronisees => _nonSynchronisees;

  /// Retourne la dernière mesure enregistrée
  MesureGlycemie? get derniere => _mesures.isNotEmpty ? _mesures.first : null;

  /// Calcule la moyenne des glycémies
  double get moyenne {
    if (_mesures.isEmpty) return 0;
    final total = _mesures.map((m) => m.valeur).reduce((a, b) => a + b);
    return total / _mesures.length;
  }

  /// Retourne les mesures critiques (> 2.0 ou < 0.5 g/L)
  List<MesureGlycemie> get alertesCritiques =>
      _mesures.where((m) => m.estCritique).toList();

  /// Retourne les mesures d'alerte orange
  List<MesureGlycemie> get alertesOrange =>
      _mesures.where((m) => m.estAlerteOrange).toList();

  /// Initialise le provider
  MesuresProvider() {
    _sync = SyncService(_storage, _fhir);
  }

  /// Vide complètement la base de données
  Future<void> supprimerTout() async {
    await _storage.toutSupprimer();
    _mesures = [];
    _nonSynchronisees = 0;
    notifyListeners();
  }

  /// Charge toutes les mesures depuis la base de données
  Future<void> charger() async {
    _chargement = true;
    notifyListeners();
    _mesures = _storage.toutesLesMesures();
    _nonSynchronisees = _storage.mesuresNonSynchronisees().length;
    _chargement = false;
    notifyListeners();
  }

  /// Ajoute une nouvelle mesure et déclenche une synchronisation en arrière-plan
  Future<void> ajouter(MesureGlycemie mesure) async {
    await _storage.sauvegarder(mesure);
    await charger();
    _syncEnArrierePlan();
  }

  /// Supprime une mesure
  Future<void> supprimer(MesureGlycemie mesure) async {
    await _storage.supprimer(mesure);
    await charger();
  }

  /// Synchronise les mesures non synchronisées avec le serveur FHIR
  Future<void> synchroniser() async {
    final count = await _sync.synchroniser();
    if (count > 0) await charger();
  }

  // Gestion de la vérification d'intégrité FHIR
  /// Flag indiquant si une vérification FHIR est en cours
  bool _verificationFhir = false;
  bool get verificationFhir => _verificationFhir;

  /// Message de retour de la vérification FHIR
  String? _messageFhir;
  String? get messageFhir => _messageFhir;

  /// Résultat de la dernière vérification FHIR (null = jamais testée)
  bool? _derniereVerificationOk;
  bool? get derniereVerificationOk => _derniereVerificationOk;

  /// Vérifie qu'une mesure synchronisée existe bien côté serveur FHIR
  /// et que ses données sont cohérentes
  Future<void> verifierIntegriteSync() async {
    _verificationFhir = true;
    _messageFhir = null;
    notifyListeners();

    final mesuresSync =
        _mesures.where((m) => m.estSynchronisee && m.idFhir != null).toList();

    // Si aucune mesure synchronisée, informer l'utilisateur
    if (mesuresSync.isEmpty) {
      _messageFhir = 'Aucune mesure synchronisée à vérifier pour le moment.';
      _verificationFhir = false;
      _derniereVerificationOk = null;
      notifyListeners();
      return;
    }

    // Récupère la dernière mesure synchronisée du serveur FHIR
    final derniere = mesuresSync.first;
    final observationDistante =
        await _fhir.recupererObservationParId(derniere.idFhir!);

    if (observationDistante != null) {
      // Compare la valeur locale avec celle du serveur
      final coherent =
          (observationDistante.valeur - derniere.valeur).abs() < 0.01;
      _derniereVerificationOk = coherent;
      _messageFhir = coherent
          ? 'Intégrité confirmée : la dernière mesure (${derniere.valeurFormatee}) correspond bien au serveur FHIR.'
          : 'Incohérence détectée entre les données locales et le serveur FHIR.';
    } else {
      _derniereVerificationOk = false;
      _messageFhir =
          'Impossible de retrouver cette mesure sur le serveur FHIR.';
    }

    _verificationFhir = false;
    notifyListeners();
  }

  /// Lance une synchronisation en arrière-plan après 2 secondes
  /// (laisse le temps à l'UI de se mettre à jour)
  void _syncEnArrierePlan() async {
    await Future.delayed(const Duration(seconds: 2));
    await synchroniser();
  }
}
