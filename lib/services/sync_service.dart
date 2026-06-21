/// Service pour synchroniser les mesures locales avec le serveur FHIR
///
/// Gère:
/// - Vérification de la connectivité réseau
/// - Envoi des mesures non synchronisées
/// - Mise à jour du statut de synchronisation

import 'package:connectivity_plus/connectivity_plus.dart';
import 'storage_service.dart';
import 'fhir_service.dart';

/// Service singleton pour la synchronisation FHIR
class SyncService {
  /// Service de stockage local
  final StorageService _storage;

  /// Service FHIR pour l'envoi d'observations
  final FhirService _fhir;

  SyncService(this._storage, this._fhir);

  /// Vérifie si une connexion réseau est disponible
  Future<bool> estConnecte() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Synchronise toutes les mesures non synchronisées avec le serveur FHIR
  ///
  /// Étapes:
  /// 1. Vérifier la connectivité
  /// 2. Récupérer les mesures non sync
  /// 3. Envoyer chaque mesure au serveur FHIR
  /// 4. Marquer comme synchronisée et enregistrer l'ID FHIR
  /// 5. Retourner le nombre de mesures synchronisées
  Future<int> synchroniser() async {
    if (!await estConnecte()) return 0;

    final nonSync = _storage.mesuresNonSynchronisees();
    int compteur = 0;

    for (final mesure in nonSync) {
      final idFhir = await _fhir.envoyerObservation(mesure);
      if (idFhir != null) {
        await _storage.marquerSynchronisee(mesure);
        await _storage.enregistrerIdFhir(mesure, idFhir);
        compteur++;
      }
    }
    return compteur;
  }
}
