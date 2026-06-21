/// Service pour générer des rapports PDF
///
/// Gère:
/// - Génération de rapports PDF avec les mesures
/// - Sauvegarde dans le dossier Documents de l'appareil
/// - Partage et export des données

import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/mesure_glycemie.dart';

/// Service pour la génération de documents PDF
class PdfService {
  /// Génère un rapport PDF avec l'historique des mesures
  ///
  /// Le rapport contient:
  /// - En-tête avec titre et email du patient
  /// - Date de génération
  /// - Nombre total de mesures
  /// - Tableau détaillé de chaque mesure (date, valeur, moment, statut)
  ///
  /// Retourne le fichier PDF sauvegardé dans Documents
  Future<File> genererRapport(
      List<MesureGlycemie> mesures, String email) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Rapport GlycoTrack BF',
                style: const pw.TextStyle(fontSize: 24)),
          ),
          pw.Text('Patient : $email'),
          pw.Text(
              'Généré le : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
          pw.SizedBox(height: 16),
          pw.Text('Nombre de mesures : ${mesures.length}'),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Date', 'Valeur (g/L)', 'Moment', 'Statut'],
            data: mesures
                .map((m) => [
                      m.dateFormatee,
                      m.valeurFormatee,
                      m.moment,
                      m.statut,
                    ])
                .toList(),
          ),
        ],
      ),
    );

    final dossier = await getApplicationDocumentsDirectory();
    final fichier = File(
        '${dossier.path}/glycotrack_rapport_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await fichier.writeAsBytes(await pdf.save());
    return fichier;
  }
}
