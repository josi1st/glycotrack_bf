import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mesures_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/graphique_glycemie.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();
    final derniere = provider.derniere;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => provider.synchroniser(),
            tooltip: 'Synchroniser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.charger(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte dernière mesure
              if (derniere != null) ...[
                Card(
                  color: derniere.estCritique
                      ? AppTheme.alertRed.withOpacity(0.1)
                      : derniere.estAlerteOrange
                          ? AppTheme.alertOrange.withOpacity(0.1)
                          : AppTheme.accentGreen.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bloodtype_rounded,
                          size: 48,
                          color: derniere.estCritique
                              ? AppTheme.alertRed
                              : derniere.estAlerteOrange
                                  ? AppTheme.alertOrange
                                  : AppTheme.accentGreen,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dernière mesure',
                                style: TextStyle(color: Colors.grey[600])),
                            Text(derniere.valeurFormatee,
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold)),
                            Text('${derniere.statut} — ${derniere.moment}'),
                            Text(derniere.dateFormatee,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Aucune mesure enregistrée')),
                  ),
                ),

              // Statistiques
              Row(
                children: [
                  Expanded(child: _StatCard(
                    titre: 'Moyenne',
                    valeur: '${provider.moyenne.toStringAsFixed(2)} g/L',
                    icone: Icons.analytics_outlined,
                    couleur: AppTheme.primaryBlue,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    titre: 'Alertes',
                    valeur: '${provider.alertesCritiques.length + provider.alertesOrange.length}',
                    icone: Icons.warning_rounded,
                    couleur: AppTheme.alertOrange,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    titre: 'Total',
                    valeur: '${provider.mesures.length}',
                    icone: Icons.list_alt,
                    couleur: AppTheme.accentGreen,
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // Graphique
              const Text('Évolution (7 derniers jours)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: GraphiqueGlycemie(
                  mesures: provider.mesures.take(7).toList(),
                ),
              ),

              // Non synchronisées
              if (provider.nonSynchronisees > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.alertOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.alertOrange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, color: AppTheme.alertOrange),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.nonSynchronisees} mesure(s) non synchronisée(s)',
                        style: TextStyle(color: AppTheme.alertOrange),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;
  final Color couleur;

  const _StatCard({
    required this.titre,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icone, color: couleur),
            const SizedBox(height: 4),
            Text(valeur,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: couleur)),
            Text(titre, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}