import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/core/utils/formatters.dart';

void main() {
  group('Formatters.amount', () {
    test('5 x 15 000 = 75 000 Ar', () {
      expect(Formatters.amount(5 * 15000), '75 000 Ar');
    });

    test('150 000 Ar', () {
      expect(Formatters.amount(150000), '150 000 Ar');
    });

    test('270 000 Ar', () {
      expect(Formatters.amount(270000), '270 000 Ar');
    });

    test('0 Ar', () {
      expect(Formatters.amount(0), '0 Ar');
    });

    test('valeurs sous 1000 sans séparateur', () {
      expect(Formatters.amount(1), '1 Ar');
      expect(Formatters.amount(999), '999 Ar');
    });

    test('1 000 000 Ar', () {
      expect(Formatters.amount(1000000), '1 000 000 Ar');
    });

    test('montant négatif conservé', () {
      expect(Formatters.amount(-45000), '-45 000 Ar');
    });
  });

  group('Formatters.quantity', () {
    test('utilise le singulier pour 1', () {
      expect(Formatters.quantity(1), '1 sac');
    });

    test('utilise le pluriel au-delà de 1', () {
      expect(Formatters.quantity(5), '5 sacs');
      expect(Formatters.quantity(125), '125 sacs');
    });

    test('0 reste au pluriel', () {
      expect(Formatters.quantity(0), '0 sacs');
    });
  });

  group('Formatters.date', () {
    test('formate jj/mm/aaaa', () {
      expect(Formatters.date(DateTime(2026, 10, 2)), '02/10/2026');
      expect(Formatters.date(DateTime(2026, 1, 5)), '05/01/2026');
    });
  });

  group('Formatters.dateTime', () {
    test('formate jj/mm/aaaa hh:mm', () {
      expect(Formatters.dateTime(DateTime(2026, 10, 2, 9, 5)), '02/10/2026 09:05');
    });
  });
}