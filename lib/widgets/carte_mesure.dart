/// Widget pour afficher une mesure de glycémie
///
/// Affiche:
/// - Valeur et statut (couleur codée)
/// - Moment et date de la mesure
/// - Note optionnelle
/// - Statut de synchronisation FHIR
/// - Bouton de suppression optionnel

import 'package:flutter/material.dart';
import '../models/mesure_glycemie.dart';
import '../theme/app_theme.dart';

/// Widget stateless pour afficher une mesure sous forme de carte
class CarteMesure extends StatelessWidget {
  /// La mesure à afficher
  final MesureGlycemie mesure;

  /// Callback optionnel pour la suppression
  final VoidCallback? onSupprimer;

  const CarteMesure({super.key, required this.mesure, this.onSupprimer});

  /// Retourne la couleur en fonction du statut de glycémie
  Color get _couleur {
    if (mesure.estCritique) return AppTheme.alertRed;
    if (mesure.estAlerteOrange) return AppTheme.alertOrange;
    return AppTheme.accentGreen;
  }

  /// Retourne l'icône en fonction du statut de glycémie
  IconData get _icone {
    if (mesure.estCritique) return Icons.warning_rounded;
    if (mesure.estAlerteOrange) return Icons.warning_amber_rounded;
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _couleur.withOpacity(0.15),
          child: Icon(_icone, color: _couleur),
        ),
        title: Text(
          mesure.valeurFormatee,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _couleur,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mesure.statut, style: TextStyle(color: _couleur)),
            Text('${mesure.moment} — ${mesure.dateFormatee}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (mesure.note.isNotEmpty)
              Text(mesure.note, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mesure.estSynchronisee ? Icons.cloud_done : Icons.cloud_off,
              size: 16,
              color:
                  mesure.estSynchronisee ? AppTheme.accentGreen : Colors.grey,
            ),
            if (onSupprimer != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: onSupprimer,
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
