import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/mesures_provider.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import 'package:open_filex/open_filex.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final AuthService _auth = AuthService();
  String? _email;

  @override
  void initState() {
    super.initState();
    _auth.lireEmail().then((e) => setState(() => _email = e));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryBlue,
              child: const Icon(Icons.person, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(_email ?? 'Utilisateur',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),

          // Infos
          _Section('Statistiques personnelles', [
            _InfoTile(Icons.list_alt, 'Total mesures', '${provider.mesures.length}'),
            _InfoTile(Icons.analytics, 'Moyenne glycémie',
                '${provider.moyenne.toStringAsFixed(2)} g/L'),
            _InfoTile(Icons.cloud_done, 'Synchronisées',
                '${provider.mesures.where((m) => m.estSynchronisee).length}'),
          ]),

          const SizedBox(height: 16),
          _Section('Données & Confidentialité', [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Supprimer toutes mes données'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Supprimer tout ?'),
                    content: const Text(
                        'Toutes vos mesures seront supprimées définitivement.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  // TODO: implémenter suppression complète
                }
              },
            ),
            ListTile(
              leading: Icon(
                provider.derniereVerificationOk == true
                    ? Icons.verified
                    : provider.derniereVerificationOk == false
                        ? Icons.error_outline
                        : Icons.cloud_sync,
                color: provider.derniereVerificationOk == true
                    ? AppTheme.accentGreen
                    : provider.derniereVerificationOk == false
                        ? AppTheme.alertRed
                        : AppTheme.primaryBlue,
              ),
              title: const Text('Vérifier l\'intégrité avec le serveur FHIR'),
              subtitle: provider.messageFhir != null
                  ? Text(provider.messageFhir!, style: const TextStyle(fontSize: 12))
                  : const Text('Confirme que vos données synchronisées sont bien sur le serveur',
                      style: TextStyle(fontSize: 12)),
              trailing: provider.verificationFhir
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right),
              onTap: provider.verificationFhir
                  ? null
                  : () => provider.verifierIntegriteSync(),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active, color: AppTheme.primaryBlue),
              title: const Text('Activer le rappel quotidien (8h00)'),
              subtitle: const Text('Recevoir une notification pour mesurer sa glycémie',
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await NotificationService().planifierRappelQuotidien(heure: 8, minute: 0);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rappel quotidien activé à 8h00')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryBlue),
              title: const Text('Exporter mes données en PDF'),
              subtitle: const Text('Générer un rapport complet',
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final fichier = await PdfService().genererRapport(
                  provider.mesures, _email ?? 'Utilisateur',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF généré avec succès')),
                  );
                }
                await OpenFilex.open(fichier.path);
              },
            ),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  final List<Widget> enfants;
  const _Section(this.titre, this.enfants);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                color: AppTheme.primaryBlue)),
        const SizedBox(height: 4),
        Card(child: Column(children: enfants)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;
  const _InfoTile(this.icone, this.label, this.valeur);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone, color: AppTheme.primaryBlue),
      title: Text(label),
      trailing: Text(valeur,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}