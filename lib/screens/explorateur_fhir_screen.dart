import 'package:flutter/material.dart';
import '../services/fhir_service.dart';
import '../theme/app_theme.dart';

class ExplorateurFhirScreen extends StatefulWidget {
  const ExplorateurFhirScreen({super.key});

  @override
  State<ExplorateurFhirScreen> createState() => _ExplorateurFhirScreenState();
}

class _ExplorateurFhirScreenState extends State<ExplorateurFhirScreen> {
  final FhirService _fhir = FhirService();
  bool _chargement = true;
  String? _erreur;
  List<ObservationFhir> _observations = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() { _chargement = true; _erreur = null; });

    final resultats = await _fhir.explorerObservationsServeur();

    setState(() {
      _observations = resultats;
      _chargement = false;
      if (resultats.isEmpty) {
        _erreur = 'Aucune observation récupérée. Vérifiez votre connexion réseau.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorateur FHIR'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _charger),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryBlue.withOpacity(0.08),
            child: const Text(
              'Cette page interroge en direct le serveur public FHIR (hapi.fhir.org) '
              'via une requête GET indépendante, afin de consulter les dernières '
              'observations de glycémie disponibles, indépendamment de vos propres envois.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          if (_chargement)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_erreur != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_erreur!, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _observations.length,
                itemBuilder: (_, i) {
                  final obs = _observations[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.bloodtype_outlined, color: AppTheme.primaryBlue),
                      title: Text('${obs.valeur.toStringAsFixed(2)} g/L'),
                      subtitle: Text(
                        'ID FHIR : ${obs.id}\n'
                        '${obs.date.day}/${obs.date.month}/${obs.date.year}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}