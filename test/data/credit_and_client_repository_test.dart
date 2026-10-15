import 'package:flutter_test/flutter_test.dart';

import 'package:saribao/core/errors/app_exception.dart';
import 'package:saribao/data/models/client.dart';
import 'package:saribao/data/repositories/payment_repository.dart';
import 'package:saribao/data/repositories/sale_repository.dart';

import '../helpers/test_database.dart';

/// Crédits clients et paiements : la logique de suivi des dettes.
void main() {
  late TestDatabase db;

  setUp(() async {
    db = await TestDatabase.create();
  });

  tearDown(() async {
    await TestDatabase.tearDown();
  });

  SaleRepository salesFor() => db.dependencies.saleRepository;
  PaymentRepository paymentsFor() => db.dependencies.paymentRepository;

  group('Suivi des crédits', () {
    test('crédit de 25 000 - paiement 10 000 = 15 000 restant', () async {
      final int clientId = await db.dependencies.clientRepository.create(
        const Client(name: 'Rakoto'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 20,
        purchasePricePerBag: 12000,
      );

      // Vente de 5 sacs à 15 000 = 75 000, dont 50 000 payés => 25 000 dus.
      await salesFor().createSale(
        clientId: clientId,
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 50000,
      );
      expect(await paymentsFor().getClientCredit(clientId), 25000);

      await paymentsFor().recordPayment(clientId: clientId, amount: 10000);
      expect(await paymentsFor().getClientCredit(clientId), 15000);
    });

    test('crédit à 0 quand tout est réglé', () async {
      final int clientId = await db.dependencies.clientRepository.create(
        const Client(name: 'Rasoanaivo'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 20,
        purchasePricePerBag: 12000,
      );

      await salesFor().createSale(
        clientId: clientId,
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 75000,
      );

      expect(await paymentsFor().getClientCredit(clientId), 0);
    });

    test('paiement supérieur au crédit refusé', () async {
      final int clientId = await db.dependencies.clientRepository.create(
        const Client(name: 'Andrianina'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 20,
        purchasePricePerBag: 12000,
      );
      await salesFor().createSale(
        clientId: clientId,
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 0,
      );

      await expectLater(
        paymentsFor().recordPayment(clientId: clientId, amount: 75001),
        throwsA(isA<ValidationException>()),
      );
      expect(await paymentsFor().getClientCredit(clientId), 75000);
    });

    test('paiement de 0 ou négatif refusé', () {
      expect(
        () => PaymentRepository.validate(amount: 0, clientCredit: 1000),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => PaymentRepository.validate(amount: -500, clientCredit: 1000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('paiement imputé sur une vente clôt son crédit', () async {
      final int clientId = await db.dependencies.clientRepository.create(
        const Client(name: 'Voahangy'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 20,
        purchasePricePerBag: 12000,
      );

      final int saleId = await _lastSaleId(db);
      // Une vente à crédit pur de 75 000.
      await salesFor().createSale(
        clientId: clientId,
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 0,
      );
      final int targetSaleId = (await salesFor().getAll()).first.id!;
      expect(targetSaleId, greaterThanOrEqualTo(saleId));

      await paymentsFor().recordPayment(
        clientId: clientId,
        amount: 75000,
        saleId: targetSaleId,
      );

      expect(await paymentsFor().getClientCredit(clientId), 0);

      final updated = (await salesFor().getAll()).first;
      expect(updated.paymentStatus, 'PAID');
      expect(updated.creditAmount, 0);
    });

    test('total des crédits ouverts tous clients confondus', () async {
      final int a = await db.dependencies.clientRepository.create(
        const Client(name: 'Client A'),
      );
      final int b = await db.dependencies.clientRepository.create(
        const Client(name: 'Client B'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 100,
        purchasePricePerBag: 12000,
      );

      await salesFor().createSale(
        clientId: a,
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 0,
      );
      await salesFor().createSale(
        clientId: b,
        quantity: 3,
        unitPrice: 15000,
        paidAmount: 0,
      );

      expect(await paymentsFor().getTotalOutstandingCredit(), 120000);
    });

    test('clients endettés triés par crédit décroissant', () async {
      final int small = await db.dependencies.clientRepository.create(
        const Client(name: 'Petit'),
      );
      final int big = await db.dependencies.clientRepository.create(
        const Client(name: 'Grand'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 100,
        purchasePricePerBag: 12000,
      );

      await salesFor().createSale(
        clientId: small,
        quantity: 2,
        unitPrice: 15000,
        paidAmount: 0,
      );
      await salesFor().createSale(
        clientId: big,
        quantity: 10,
        unitPrice: 15000,
        paidAmount: 0,
      );

      final credits = await paymentsFor().getClientsWithCredit();
      expect(credits.length, 2);
      expect(credits.first.clientId, big);
      expect(credits.first.credit, 150000);
      expect(credits.last.credit, 30000);
    });

    test('un client soldé n\'apparaît plus dans la liste des débiteurs', () async {
      final int clientId = await db.dependencies.clientRepository.create(
        const Client(name: 'Soldé'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 20,
        purchasePricePerBag: 12000,
      );
      await salesFor().createSale(
        clientId: clientId,
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 0,
      );
      await paymentsFor().recordPayment(clientId: clientId, amount: 75000);

      expect(await paymentsFor().getClientsWithCredit(), isEmpty);
    });
  });

  group('Clients', () {
    test('création et lecture', () async {
      final int id = await db.dependencies.clientRepository.create(
        const Client(name: 'Rakoto', phone: '034 00 000'),
      );

      final client = await db.dependencies.clientRepository.getById(id);
      expect(client!.name, 'Rakoto');
      expect(client.phone, '034 00 000');
    });

    test('nom obligatoire', () {
      expect(
        () => db.dependencies.clientRepository.create(const Client(name: '  ')),
        throwsA(isA<ValidationException>()),
      );
    });

    test('recherche par nom', () async {
      await db.dependencies.clientRepository.create(const Client(name: 'Rakoto'));
      await db.dependencies.clientRepository.create(
        const Client(name: 'Rasoanaivo'),
      );

      final results = await db.dependencies.clientRepository.search('Rasoa');
      expect(results.length, 1);
      expect(results.first.name, 'Rasoanaivo');
    });

    test('client avec ventes non supprimable', () async {
      final int clientId = await db.dependencies.clientRepository.create(
        const Client(name: 'Avec ventes'),
      );
      await db.dependencies.arrivalRepository.createArrival(
        quantity: 20,
        purchasePricePerBag: 12000,
      );
      await salesFor().createSale(
        clientId: clientId,
        quantity: 5,
        unitPrice: 15000,
        paidAmount: 0,
      );

      await expectLater(
        db.dependencies.clientRepository.delete(clientId),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });
}

/// Identifiant de la dernière vente créée.
Future<int> _lastSaleId(TestDatabase db) async {
  final sales = await db.dependencies.saleRepository.getAll();
  return sales.isEmpty ? 0 : sales.first.id!;
}
