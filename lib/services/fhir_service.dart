import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mesure_glycemie.dart';

class ObservationFhir {
  final String id;
  final double valeur;
  final DateTime date;

  ObservationFhir({required this.id, required this.valeur, required this.date});

  factory ObservationFhir.depuisJson(Map<String, dynamic> json) {
    return ObservationFhir(
      id: json['id'] ?? '',
      valeur: (json['valueQuantity']?['value'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['effectiveDateTime'] ?? '') ?? DateTime.now(),
    );
  }
}

class FhirService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR4';

  /// Envoie une mesure vers le serveur FHIR et retourne l'ID FHIR créé
  Future<String?> envoyerObservation(MesureGlycemie mesure) async {
    try {
      final body = jsonEncode({
        'resourceType': 'Observation',
        'status': 'final',
        'code': {
          'coding': [{
            'system': 'http://loinc.org',
            'code': '2339-0',
            'display': 'Glucose [Mass/volume] in Blood'
          }]
        },
        'valueQuantity': {
          'value': mesure.valeur,
          'unit': 'g/L',
          'system': 'http://unitsofmeasure.org',
          'code': 'g/L'
        },
        'effectiveDateTime': mesure.date.toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/Observation'),
        headers: {'Content-Type': 'application/fhir+json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Récupère une observation précise par son ID FHIR (vérification après sync)
  Future<ObservationFhir?> recupererObservationParId(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Observation/$id'),
        headers: {'Accept': 'application/fhir+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ObservationFhir.depuisJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Récupère les dernières observations de glycémie sur le serveur (aperçu général)
  Future<List<ObservationFhir>> recupererDernieresObservations({int limite = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Observation?code=2339-0&_count=$limite&_sort=-date'),
        headers: {'Accept': 'application/fhir+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entries = data['entry'] as List? ?? [];
        return entries
            .map((e) => ObservationFhir.depuisJson(e['resource']))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}