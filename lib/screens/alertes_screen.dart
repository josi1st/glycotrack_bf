/// Écran d'affichage des alertes
///
/// Affiche les mesures problématiques:
/// - Alertes critiques (> 2.0 ou < 0.5 g/L)
/// - Alertes modérées/orange (1.26-2.0 ou 0.5-0.70 g/L)
///
/// Permet à l'utilisateur de vérifier rapidement les valeurs anormales

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mesures_provider.dart';
import '../widgets/carte_mesure.dart';
import '../theme/app_theme.dart';

/// Écran stateless affichant les alertes
class AlertesScreen extends StatelessWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();
    // Récupère les mesures critiques et orange
    final critiques = provider.alertesCritiques;
    final orange = provider.alertesOrange;

    return Scaffold(
      appBar: AppBar(title: const Text('Centre d\'Alertes')),
      // Affiche un message si aucune alerte
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
                // Section des alertes critiques
                if (critiques.isNotEmpty) ...[
                  _SectionHeader('Alertes Critiques', AppTheme.alertRed),
                  ...critiques.map((m) => CarteMesure(mesure: m)),
                ],
                // Section des alertes modérées
                if (orange.isNotEmpty) ...[
                  _SectionHeader('Alertes Modérées', AppTheme.alertOrange),
                  ...orange.map((m) => CarteMesure(mesure: m)),
                ],
              ],
            ),
    );
  }
}

/// Widget privé pour un en-tête de section d'alerte
class _SectionHeader extends StatelessWidget {
  /// Titre de la section (ex: "Alertes Critiques")
  final String titre;

  /// Couleur correspondant au type d'alerte
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
