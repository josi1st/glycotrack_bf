/// Modèle pour représenter une mesure de glycémie
///
/// Utilise Hive pour la persistance locale avec chiffrement.
/// Contient la logique métier pour déterminer le statut et les alertes.

import 'package:hive/hive.dart';

part 'mesure_glycemie.g.dart';

/// Entité Hive pour stocker une mesure de glycémie
///
/// Champs:
/// - valeur: glycémie en g/L
/// - date: moment de la mesure
/// - moment: contexte (À jeun, Après repas, etc.)
/// - note: annotations optionnelles
/// - estSynchronisee: flag de synchronisation FHIR
/// - idFhir: identifiant du serveur FHIR
@HiveType(typeId: 0)
class MesureGlycemie extends HiveObject {
  /// Valeur de glycémie en g/L (0-5 g/L généralement)
  @HiveField(0)
  late double valeur;

  /// Date et heure de la mesure
  @HiveField(1)
  late DateTime date;

  /// Contexte: "À jeun", "Après repas", "Au coucher", "Autre"
  @HiveField(2)
  late String moment;

  /// Notes libres optionnelles de l'utilisateur
  @HiveField(3)
  late String note;

  /// Indique si la mesure a été synchronisée au serveur FHIR
  @HiveField(4)
  bool estSynchronisee = false;

  /// Identifiant de l'observation sur le serveur FHIR
  @HiveField(5)
  String? idFhir;

  /// Retourne le statut de la glycémie: "Normale", "Élevée", "Basse"
  String get statut {
    if (valeur > 1.26) return 'Élevée';
    if (valeur < 0.70) return 'Basse';
    return 'Normale';
  }

  /// True si la glycémie est critique (> 2.0 ou < 0.5 g/L)
  bool get estCritique => valeur > 2.0 || valeur < 0.5;

  /// True si alerte orange (1.26-2.0 ou 0.5-0.70 g/L)
  bool get estAlerteOrange =>
      (valeur > 1.26 && valeur <= 2.0) || (valeur >= 0.5 && valeur < 0.70);

  /// Formate la date pour affichage: "JJ/MM/AAAA à HHhMM"
  String get dateFormatee {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}h'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formate la valeur pour affichage: "X.XX g/L"
  String get valeurFormatee => '${valeur.toStringAsFixed(2)} g/L';
}
