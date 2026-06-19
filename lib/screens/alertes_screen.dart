import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mesures_provider.dart';
import '../widgets/carte_mesure.dart';
import '../theme/app_theme.dart';

class AlertesScreen extends StatelessWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();
    final critiques = provider.alertesCritiques;
    final orange = provider.alertesOrange;

    return Scaffold(
      appBar: AppBar(title: const Text('Centre d\'Alertes')),
      body: critiques.isEmpty && orange.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: AppTheme.accentGreen),
                  const SizedBox(height: 8),
                  const Text('Aucune alerte active',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              children: [
                if (critiques.isNotEmpty) ...[
                  _SectionHeader('Alertes Critiques', AppTheme.alertRed),
                  ...critiques.map((m) => CarteMesure(mesure: m)),
                ],
                if (orange.isNotEmpty) ...[
                  _SectionHeader('Alertes Modérées', AppTheme.alertOrange),
                  ...orange.map((m) => CarteMesure(mesure: m)),
                ],
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String titre;
  final Color couleur;

  const _SectionHeader(this.titre, this.couleur);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(titre,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: couleur)),
    );
  }
}