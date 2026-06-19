import 'package:flutter_test/flutter_test.dart';
import 'package:glycotrack_bf/models/mesure_glycemie.dart';

void main() {
  MesureGlycemie creer(double valeur) => MesureGlycemie()
    ..valeur = valeur
    ..date = DateTime.now()
    ..moment = 'À jeun'
    ..note = '';

  group('Statut glycémique', () {
    test('Normale entre 0.70 et 1.26', () {
      expect(creer(1.0).statut, equals('Normale'));
    });
    test('Élevée si > 1.26', () {
      expect(creer(1.5).statut, equals('Élevée'));
    });
    test('Basse si < 0.70', () {
      expect(creer(0.5).statut, equals('Basse'));
    });
  });

  group('Alertes critiques', () {
    test('Critique si > 2.0', () {
      expect(creer(2.5).estCritique, isTrue);
    });
    test('Critique si < 0.5', () {
      expect(creer(0.3).estCritique, isTrue);
    });
    test('Pas critique si normale', () {
      expect(creer(1.0).estCritique, isFalse);
    });
  });

  group('Formatage', () {
    test('valeurFormatee contient g/L', () {
      expect(creer(1.1).valeurFormatee, contains('g/L'));
    });
  });
}