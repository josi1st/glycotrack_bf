import 'package:hive/hive.dart';

part 'mesure_glycemie.g.dart';

@HiveType(typeId: 0)
class MesureGlycemie extends HiveObject {
  @HiveField(0)
  late double valeur;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String moment;

  @HiveField(3)
  late String note;

  @HiveField(4)
  bool estSynchronisee = false;

  String get statut {
    if (valeur > 1.26) return 'Élevée';
    if (valeur < 0.70) return 'Basse';
    return 'Normale';
  }

  bool get estCritique => valeur > 2.0 || valeur < 0.5;

  bool get estAlerteOrange =>
      (valeur > 1.26 && valeur <= 2.0) || (valeur >= 0.5 && valeur < 0.70);

  String get dateFormatee {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}h'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String get valeurFormatee => '${valeur.toStringAsFixed(2)} g/L';
}