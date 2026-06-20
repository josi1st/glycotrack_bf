import 'package:connectivity_plus/connectivity_plus.dart';
import 'storage_service.dart';
import 'fhir_service.dart';

class SyncService {
  final StorageService _storage;
  final FhirService _fhir;

  SyncService(this._storage, this._fhir);

  Future<bool> estConnecte() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

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