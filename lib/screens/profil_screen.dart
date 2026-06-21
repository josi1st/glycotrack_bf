import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/mesures_provider.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import 'package:open_filex/open_filex.dart';
import 'explorateur_fhir_screen.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final AuthService _auth = AuthService();
  final NotificationService _notif = NotificationService();

  String? _nom;
  String? _telephone;
  Map<String, String>? _infosRappel;
  bool _suppressionEnCours = false;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
    _chargerInfosRappel();
  }

  Future<void> _chargerProfil() async {
    final nom = await _auth.lireNom();
    final telephone = await _auth.lireTelephone();
    if (!mounted) return;
    setState(() {
      _nom = nom;
      _telephone = telephone;
    });
  }

  Future<void> _chargerInfosRappel() async {
    final infos = await _notif.infosRappelSauvegarde();
    if (!mounted) return;
    setState(() { _infosRappel = infos; });
  }

  String _formaterDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return '${jours[date.weekday - 1]} ${date.day}/${date.month} à '
          '${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _choisirHeureRappel() async {
    final initial = _infosRappel != null
        ? TimeOfDay(
            hour: int.parse(_infosRappel!['heure']!),
            minute: int.parse(_infosRappel!['minute']!),
          )
        : const TimeOfDay(hour: 8, minute: 0);

    final heureChoisie = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Choisir l\'heure du rappel',
    );
    if (heureChoisie == null) return;

    await _notif.planifierRappelQuotidien(
      heure: heureChoisie.hour,
      minute: heureChoisie.minute,
    );

    await _chargerInfosRappel();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          'Rappel activé tous les jours à ${heureChoisie.format(context)}',
        )),
      );
    }
  }

  Future<void> _annulerRappel() async {
    await _notif.annulerRappels();
    await _chargerInfosRappel();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rappel annulé')),
      );
    }
  }

  Future<void> _supprimerToutesLesDonnees() async {
    setState(() { _suppressionEnCours = true; });

    final provider = context.read<MesuresProvider>();

    // 1. Supprimer toutes les mesures (Hive)
    await provider.supprimerTout();

    // 2. Annuler les rappels programmés
    await _notif.annulerRappels();

    // 3. Supprimer le profil (nom, téléphone, consentement RGPD)
    await _auth.supprimerProfilComplet();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes vos données ont été supprimées')),
    );

    // Retour à l'écran de connexion (l'utilisateur devra recréer un profil)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
            child: Text(_nom ?? 'Utilisateur',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (_telephone != null)
            Center(
              child: Text('+226 $_telephone',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ),
          const SizedBox(height: 24),

          // Statistiques personnelles
          _Section('Statistiques personnelles', [
            _InfoTile(Icons.list_alt, 'Total mesures', '${provider.mesures.length}'),
            _InfoTile(Icons.analytics, 'Moyenne glycémie',
                '${provider.moyenne.toStringAsFixed(2)} g/L'),
            _InfoTile(Icons.cloud_done, 'Synchronisées',
                '${provider.mesures.where((m) => m.estSynchronisee).length}'),
          ]),

          const SizedBox(height: 16),

          // Serveur FHIR
          _Section('Serveur FHIR', [
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
              leading: const Icon(Icons.travel_explore, color: AppTheme.primaryBlue),
              title: const Text('Explorer le serveur FHIR'),
              subtitle: const Text('Consulter les observations disponibles en direct',
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExplorateurFhirScreen()),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Notifications
          _Section('Rappels & Notifications', [
            ListTile(
              leading: Icon(
                _infosRappel != null ? Icons.alarm_on : Icons.alarm_off,
                color: _infosRappel != null ? AppTheme.accentGreen : Colors.grey,
              ),
              title: Text(_infosRappel != null
                  ? 'Rappel actif : ${_infosRappel!['heure']!.padLeft(2, '0')}h${_infosRappel!['minute']!.padLeft(2, '0')}'
                  : 'Aucun rappel programmé'),
              subtitle: Text(
                _infosRappel != null
                    ? 'Prochain déclenchement estimé : ${_formaterDate(_infosRappel!['prochaine']!)}'
                    : 'Touchez pour choisir une heure de rappel quotidien',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: _infosRappel != null
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _annulerRappel,
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _choisirHeureRappel,
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none, color: Colors.grey),
              title: const Text('Tester une notification maintenant'),
              subtitle: const Text('Vérifier que les notifications fonctionnent',
                  style: TextStyle(fontSize: 12)),
              onTap: () async {
                await _notif.testerNotificationImmediate();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification de test envoyée — vérifiez vos notifications')),
                  );
                }
              },
            ),
          ]),

          const SizedBox(height: 16),

          // Données & Confidentialité
          _Section('Données & Confidentialité', [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryBlue),
              title: const Text('Exporter mes données en PDF'),
              subtitle: const Text('Générer un rapport complet',
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final fichier = await PdfService().genererRapport(
                  provider.mesures, _nom ?? 'Utilisateur',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF généré avec succès')),
                  );
                }
                await OpenFilex.open(fichier.path);
              },
            ),
            ListTile(
              leading: _suppressionEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                  : const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Supprimer toutes mes données'),
              subtitle: const Text('Mesures, profil et rappels seront effacés définitivement',
                  style: TextStyle(fontSize: 12)),
              onTap: _suppressionEnCours
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Supprimer tout ?'),
                          content: const Text(
                              'Toutes vos mesures, votre profil et vos rappels seront supprimés définitivement. Cette action est irréversible.'),
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
                      if (confirm == true) {
                        await _supprimerToutesLesDonnees();
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