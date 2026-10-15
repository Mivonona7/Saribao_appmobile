import 'package:flutter_test/flutter_test.dart';

import 'package:saribao/core/errors/app_exception.dart';
import 'package:saribao/data/models/client.dart';
import 'package:saribao/data/repositories/arrival_repository.dart';
import 'package:saribao/data/repositories/sale_repository.dart';

import '../helpers/test_database.dart';

/// Crée un client de test et renvoie son identifiant.
Future<int> _createClient(TestDatabase db, String name) {
  return db.dependencies.clientRepository.create(Client(name: name));
}

/// Règles de calcul et d'intégrité du stock, vérifiées contre une vraie
/// base SQLite (et non des mocks) : c'est ce qui prouve que les
/// transactions sont bien atomiques.
void main() {
  late TestDatabase db;

  setUp(() async {
    db = await TestDatabase.create();
  });

  tearDown(() async {
    await TestDatabase.tearDown();
  });

  ArrivalRepository arrivalsFor() => db.dependencies.arrivalRepository;
  SaleRepository salesFor() => db.dependencies.saleRepository;

  group('Calcul des montants', () {
    test('5 x 15 000 = 75 000 Ar', () {
      expect(SaleRepository.computeTotal(5, 15000), 75000);
    });

    test('crédit : 75 000 - 50 000 = 25 000 Ar', () {
      expect(SaleRepository.computeCredit(5, 15000, 50000), 25000);
    });

    test('arrivage : 100 x 12 000 = 1 200 000 Ar', () {
      expect(ArrivalRepository.computeTotal(100, 12000), 1200000);
    });
  });

  group('Validation des saisies', () {
    test('quantité < 1 refusée', () {
      expect(
        () => SaleRepository.validate(
          quantity: 0,
          unitPrice: 15000,
          paidAmount: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('prix <= 0 refusé', () {
      expect(
        () => SaleRepository.validate(
          quantity: 5,
          unitPrice: 0,
          paidAmount: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('paiement négatif refusé', () {
      expect(
        () => SaleRepository.validate(
          quantity: 5,
          unitPrice: 15000,
          paidAmount: -1,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('paiement supérieur au total refusé', () {
      expect(
        () => SaleRepository.validate(
          quantity: 5,
          unitPrice: 15000,
          paidAmount: 75001,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('paiement égal au total accepté', () {
      expect(
        () => SaleRepository.validate(
          quantity: 5,
          unitPrice: 15000,
          paidAmount: 75000,
        ),
        returnsNormally,
      );
    });
  });

  group('Stock', () {
    test('100 + 50 - 20 = 130', () async {
      await arrivalsFor().createArrival(quantity: 100, purchasePricePerBag: 12000);
      await arrivalsFor().createArrival(quantity: 50, purchasePricePerBag: 12000);
      await salesFor().createSale(quantity: 20, unitPrice: 15000, paidAmount: 0);

      expect(await salesFor().getAvailableStock(), 130);
    });

    test('stock insuffisant : 3 disponibles, 5 demandés => refus', () async {
      await arrivalsFor().createArrival(quantity: 3, purchasePricePerBag: 12000);

      await expectLater(
        salesFor().createSale(quantity: 5, unitPrice: 15000, paidAmount: 0),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('après refus, le stock est inchangé (rollback)', () async {
      await arrivalsFor().createArrival(quantity: 3, purchasePricePerBag: 12000);

      await expectLater(
        salesFor().createSale(quantity: 5, unitPrice: 15000, paidAmount: 0),
        throwsA(isA<InsufficientStockException>()),
      );

      expect(await salesFor().getAvailableStock(), 3);
    });

    test('stock ne peut jamais devenir négatif', () async {
      await arrivalsFor().createArrival(quantity: 10, purchasePricePerBag: 12000);
      await salesFor().createSale(quantity: 10, unitPrice: 15000, paidAmount: 0);

      expect(await salesFor().getAvailableStock(), 0);

      await expectLater(
        salesFor().createSale(quantity: 1, unitPrice: 15000, paidAmount: 0),
        throwsA(isA<InsufficientStockException>()),
      );
      expect(await salesFor().getAvailableStock(), 0);
    });

    test('une vente crée toujours un mouvement de stock', () async {
      await arrivalsFor().createArrival(quantity: 20, purchasePricePerBag: 12000);
      await salesFor().createSale(quantity: 5, unitPrice: 15000, paidAmount: 0);

      final movements =
          await db.dependencies.stockRepository.getMovements();
      // 1 arrivage + 1 vente
      expect(movements.length, 2);
      expect(movements.first.quantity, -5);
    });
  });

  group('Vente avec paiement', () {
    test('vente payée : crédit nul', () async {
      await arrivalsFor().createArrival(quantity: 20, purchasePricePerBag: 12000);
      final result = await salesFor().createSale(
        clientId: await _createClient(db, 'Rakoto'),
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 75000,
      );

      expect(result.stockAfter, 15);

      final all = await salesFor().getAll();
      expect(all.first.creditAmount, 0);
      expect(all.first.paidAmount, 75000);
      expect(all.first.paymentStatus, 'PAID');
    });

    test('vente à crédit : crédit = total', () async {
      await arrivalsFor().createArrival(quantity: 20, purchasePricePerBag: 12000);
      await salesFor().createSale(
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 0,
      );

      final all = await salesFor().getAll();
      expect(all.first.creditAmount, 75000);
      expect(all.first.paymentStatus, 'CREDIT');
    });

    test('vente partielle : statut PARTIAL', () async {
      await arrivalsFor().createArrival(quantity: 20, purchasePricePerBag: 12000);
      await salesFor().createSale(
        clientId: await _createClient(db, 'Rasoanaivo'),
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 50000,
      );

      final all = await salesFor().getAll();
      expect(all.first.creditAmount, 25000);
      expect(all.first.paymentStatus, 'PARTIAL');
    });

    test('paiement sans client refusé', () async {
      await arrivalsFor().createArrival(quantity: 20, purchasePricePerBag: 12000);

      await expectLater(
        salesFor().createSale(quantity: 5, unitPrice: 15000, paidAmount: 1000),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Arrivage', () {
    test('quantité < 1 refusée', () {
      expect(
        () => ArrivalRepository.validate(
          quantity: 0,
          purchasePricePerBag: 12000,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('prix d\'achat négatif refusé', () {
      expect(
        () => ArrivalRepository.validate(
          quantity: 10,
          purchasePricePerBag: -1,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('prix d\'achat à 0 accepté', () {
      expect(
        () => ArrivalRepository.validate(
          quantity: 10,
          purchasePricePerBag: 0,
        ),
        returnsNormally,
      );
    });

    test('l\'arrivage augmente le stock et l\'historique', () async {
      final result = await arrivalsFor().createArrival(
        quantity: 100,
        purchasePricePerBag: 12000,
        supplier: 'Fournisseur Test',
      );

      expect(result.stockAfter, 100);
      expect(await salesFor().getAvailableStock(), 100);

      final all = await arrivalsFor().getAll();
      expect(all.first.quantity, 100);
      expect(all.first.totalPurchaseAmount, 1200000);
      expect(all.first.supplier, 'Fournisseur Test');
    });
  });

  group('Résumé des ventes', () {
    test('agrégats sur la période', () async {
      await arrivalsFor().createArrival(quantity: 100, purchasePricePerBag: 12000);
      await salesFor().createSale(
        clientId: await _createClient(db, 'Andrianina'),
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 75000,
      );
      await salesFor().createSale(quantity: 5, unitPrice: 15000, paidAmount: 0);

      final summary = await salesFor().getSummary(
        from: DateTime.now().subtract(const Duration(days: 1)),
        to: DateTime.now().add(const Duration(days: 1)),
      );

      expect(summary.bagsSold, 10);
      expect(summary.revenue, 150000);
      expect(summary.collected, 75000);
      expect(summary.credit, 75000);
    });
  });
}
