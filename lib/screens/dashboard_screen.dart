import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mesures_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'ajout_mesure_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _auth = AuthService();
  String? _nom;

  @override
  void initState() {
    super.initState();
    _auth.lireNom().then((n) => setState(() => _nom = n));
  }

  String get _salutation {
    final heure = DateTime.now().hour;
    if (heure < 12) return 'Bonjour';
    if (heure < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();
    final derniere = provider.derniere;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GlycoTrack BF'),
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
              // Salutation personnalisée
              Text(
                '$_salutation${_nom != null ? ', ${_nom!.split(' ').first}' : ''} 👋',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Voici votre suivi glycémique du jour',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 16),

              // CTA principal — Ajouter une mesure
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AjoutMesureScreen()),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Enregistrer ma glycémie maintenant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.bloodtype_outlined, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        const Text('Aucune mesure enregistrée pour le moment',
                            textAlign: TextAlign.center),
                        const Text('Commencez par ajouter votre première mesure !',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
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

              if (provider.nonSynchronisees > 0) ...[
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
                      Expanded(
                        child: Text(
                          '${provider.nonSynchronisees} mesure(s) non synchronisée(s)',
                          style: TextStyle(color: AppTheme.alertOrange),
                        ),
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