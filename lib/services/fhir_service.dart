import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mesure_glycemie.dart';

class FhirService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR4';

  Future<bool> envoyerObservation(MesureGlycemie mesure) async {
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

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> recupererObservations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Observation?code=2339-0&_count=20'),
        headers: {'Accept': 'application/fhir+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entries = data['entry'] as List? ?? [];
        return entries.map((e) => e['resource'] as Map<String, dynamic>).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}