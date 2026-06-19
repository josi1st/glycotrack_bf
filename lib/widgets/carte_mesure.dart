import 'package:flutter/material.dart';
import '../models/mesure_glycemie.dart';
import '../theme/app_theme.dart';

class CarteMesure extends StatelessWidget {
  final MesureGlycemie mesure;
  final VoidCallback? onSupprimer;

  const CarteMesure({super.key, required this.mesure, this.onSupprimer});

  Color get _couleur {
    if (mesure.estCritique) return AppTheme.alertRed;
    if (mesure.estAlerteOrange) return AppTheme.alertOrange;
    return AppTheme.accentGreen;
  }

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
              color: mesure.estSynchronisee ? AppTheme.accentGreen : Colors.grey,
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