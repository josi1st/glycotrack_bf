import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mesures_provider.dart';
import '../widgets/graphique_glycemie.dart';
import '../theme/app_theme.dart';

class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Courbe d\'évolution',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: GraphiqueGlycemie(mesures: provider.mesures),
            ),
            const SizedBox(height: 24),
            // Résumé statistique
            const Text('Résumé',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _LigneStat('Nombre de mesures', '${provider.mesures.length}'),
                    _LigneStat('Moyenne', '${provider.moyenne.toStringAsFixed(2)} g/L'),
                    _LigneStat('Alertes critiques', '${provider.alertesCritiques.length}',
                        couleur: AppTheme.alertRed),
                    _LigneStat('Alertes modérées', '${provider.alertesOrange.length}',
                        couleur: AppTheme.alertOrange),
                    _LigneStat('Non synchronisées', '${provider.nonSynchronisees}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneStat extends StatelessWidget {
  final String label;
  final String valeur;
  final Color? couleur;

  const _LigneStat(this.label, this.valeur, {this.couleur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(valeur,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleur ?? AppTheme.primaryBlue)),
        ],
      ),
    );
  }
}