import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mesures_provider.dart';
import '../widgets/graphique_glycemie.dart';
import '../widgets/carte_mesure.dart';
import '../theme/app_theme.dart';

class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: provider.mesures.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Aucune mesure enregistrée', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => provider.charger(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Graphique
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
                  const SizedBox(height: 24),

                  // Liste détaillée de toutes les mesures
                  const Text('Toutes les mesures',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...provider.mesures.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: CarteMesure(
                          mesure: m,
                          onSupprimer: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Supprimer ?'),
                                content: const Text('Cette mesure sera supprimée définitivement.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Annuler')),
                                  TextButton(onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Supprimer',
                                          style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.supprimer(m);
                            }
                          },
                        ),
                      )),
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