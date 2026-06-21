/// Dialog d'affichage et d'acceptation du consentement RGPD
///
/// Affiche:
/// - Le texte du consentement
/// - Les droits de l'utilisateur en matière de données
/// - Boutons d'acceptation/refus
///
/// Permet à l'utilisateur d'accepter les conditions avant d'utiliser l'app

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dialog stateless pour le consentement RGPD
class ConsentementDialog extends StatelessWidget {
  /// Callback lorsque l'utilisateur accepte
  final VoidCallback onAccepter;

  /// Callback lorsque l'utilisateur refuse
  final VoidCallback onRefuser;

  const ConsentementDialog({
    super.key,
    required this.onAccepter,
    required this.onRefuser,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.shield_outlined, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          const Text('Consentement RGPD'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avant d\'utiliser GlycoTrack BF, veuillez lire et accepter notre politique de confidentialité.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildPoint(Icons.storage,
                'Vos données de glycémie sont stockées localement et chiffrées sur votre appareil.'),
            _buildPoint(Icons.sync,
                'Avec votre accord, elles peuvent être synchronisées avec un serveur FHIR sécurisé.'),
            _buildPoint(Icons.person,
                'Aucune donnée personnelle n\'est partagée avec des tiers sans votre consentement.'),
            _buildPoint(Icons.delete,
                'Vous pouvez supprimer vos données à tout moment depuis les paramètres.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onRefuser,
          child: const Text('Refuser', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: onAccepter,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            minimumSize: const Size(120, 44),
          ),
          child: const Text('J\'accepte'),
        ),
      ],
    );
  }

  Widget _buildPoint(IconData icon, String texte) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Expanded(child: Text(texte, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
