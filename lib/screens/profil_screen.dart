import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/mesures_provider.dart';
import '../theme/app_theme.dart';

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