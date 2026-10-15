import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/app/app.dart';
import 'package:saribao/app/bootstrap.dart';
import 'package:saribao/core/di/app_dependencies.dart';
import 'package:saribao/data/models/client.dart';
import 'package:saribao/presentation/dashboard/main_shell.dart';
import 'package:saribao/presentation/widgets/loading_view.dart';

import 'test_database.dart';

/// Scénario métier partagé par les tests widget.
///
/// 100 sacs achetés, puis 18 sacs vendus dont 50 000 Ar encaissés sur une
/// seule vente. Il reste donc 82 sacs en stock, 270 000 Ar de CA du jour et
/// 100 000 Ar de crédit à récupérer.
const int seededStock = 82;
const int seededSalesQuantity = 18;
const int seededRevenue = 270000;
const int seededOutstandingCredit = 100000;

/// Monte l'application complète sur une base SQLite en mémoire.
///
/// `SaribaoApp` lit la vraie base : sans ce harnais, le splash échouerait car
/// `sqflite` n'a pas de canal plateforme sous `flutter test`.
Future<TestDatabase> pumpSaribaoApp(
  WidgetTester tester, {
  bool seed = true,
}) async {
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final TestDatabase? harness = await tester.runAsync(() async {
    final TestDatabase created = await TestDatabase.create();
    if (seed) await seedBusinessData(created.dependencies);
    return created;
  });
  if (harness == null) {
    fail('La base de test n\'a pas pu être initialisée.');
  }
  AppBootstrap.resetForTest();

  addTearDown(() async {
    AppBootstrap.resetForTest();
    await TestDatabase.tearDown();
  });

  await tester.pumpWidget(const SaribaoApp());
  await settleApp(tester);

  return harness;
}

/// Laisse l'application atteindre son état stable.
///
/// `pumpAndSettle` est inutilisable ici : `LoadingView` anime un
/// `CircularProgressIndicator` indéfiniment, donc la boucle de pump ne se
/// termine jamais. De plus, SQLite FFI fait du vrai travail hors du temps
/// simulé. On alterne donc des fenêtres de temps réel et des pumps bornés,
/// jusqu'à ce qu'aucun indicateur de chargement ne reste à l'écran.
Future<void> settleApp(WidgetTester tester, {int maxCycles = 40}) async {
  for (int cycle = 0; cycle < maxCycles; cycle++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));

    if (!_isBusy(tester)) {
      await tester.pump(const Duration(milliseconds: 50));
      return;
    }
  }
  fail('L\'application ne s\'est pas stabilisée après $maxCycles cycles.');
}

/// `true` tant que le splash ou un écran de chargement est encore affiché.
bool _isBusy(WidgetTester tester) {
  if (find.byType(MainShell).evaluate().isEmpty) return true;
  if (find.byType(LoadingView).evaluate().isNotEmpty) return true;
  // Le message est localisé : il dépend de la langue active.
  return find.text('Chargement de vos données...').evaluate().isNotEmpty ||
      find.text('Miandry ny angonareo...').evaluate().isNotEmpty;
}

/// Remplit la base avec le scénario décrit par les constantes ci-dessus.
Future<void> seedBusinessData(AppDependencies dependencies) async {
  await dependencies.arrivalRepository.createArrival(
    quantity: 100,
    purchasePricePerBag: 10000,
    supplier: 'Fournisseur test',
  );

  final int clientId = await dependencies.clientRepository.create(
    const Client(name: 'Aminata Traoré', phone: '034 00 000 00'),
  );
  final int otherClientId = await dependencies.clientRepository.create(
    const Client(name: 'Boulangerie Raha', phone: '034 11 111 11'),
  );

  // 10 sacs à 15 000 Ar, dont 50 000 Ar réglés : 100 000 Ar de crédit.
  await dependencies.saleRepository.createSale(
    clientId: clientId,
    quantity: 10,
    unitPrice: 15000,
    paidAmount: 50000,
  );

  // 8 sacs à 15 000 Ar, intégralement réglés.
  await dependencies.saleRepository.createSale(
    clientId: otherClientId,
    quantity: 8,
    unitPrice: 15000,
    paidAmount: 120000,
  );
}

/// Fait défiler le dashboard jusqu'à ce que [finder] soit visible.
Future<void> scrollDashboardTo(WidgetTester tester, Finder finder) async {
  final Finder scrollable = find.byType(CustomScrollView).first;
  for (int i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -250));
    await tester.pumpAndSettle();
  }
}
