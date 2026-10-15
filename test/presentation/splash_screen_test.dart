import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/app/app.dart';
import 'package:saribao/core/constants/app_constants.dart';
import 'package:saribao/core/utils/formatters.dart';
import 'package:saribao/presentation/widgets/app_logo.dart';

import '../helpers/app_harness.dart';

void main() {
  testWidgets('le splash affiche le logo, le nom et le chargement', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SaribaoApp());

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);
    expect(find.text('Chargement...'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('le splash passe au dashboard sans délai artificiel', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    expect(find.text('Bonjour'), findsOneWidget);
    expect(find.byIcon(Icons.waving_hand_outlined), findsOneWidget);
    expect(find.text('STOCK DISPONIBLE'), findsOneWidget);
  });

  testWidgets('le dashboard affiche le stock issu de la base', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    expect(find.text('STOCK DISPONIBLE'), findsOneWidget);
    expect(find.text('$seededStock'), findsOneWidget);
    expect(find.text('SACS'), findsOneWidget);
  });

  testWidgets('le dashboard affiche le CA et les quantités du jour', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    // `StatCard` et `AppButton` rendu leur libellé en capitales.
    await scrollDashboardTo(tester, find.text('VENTES DU JOUR'));

    expect(find.text('VENTES DU JOUR'), findsOneWidget);
    expect(find.text(Formatters.quantity(seededSalesQuantity)), findsOneWidget);

    await scrollDashboardTo(tester, find.text('CA DU JOUR'));

    expect(find.text('CA DU JOUR'), findsOneWidget);
    expect(find.text(Formatters.amount(seededRevenue)), findsOneWidget);
  });

  testWidgets('le dashboard affiche les crédits restant à récupérer', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    await scrollDashboardTo(tester, find.text('CRÉDITS À RÉCUPÉRER'));

    expect(find.text('CRÉDITS À RÉCUPÉRER'), findsOneWidget);
    expect(
      find.text(Formatters.amount(seededOutstandingCredit)),
      findsOneWidget,
    );
  });

  testWidgets('le dashboard liste les dernières ventes', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    // La section est sous la ligne de flottaison : les slivers sont construits
    // paresseusement, il faut descendre pour qu'elle existe.
    await scrollDashboardTo(tester, find.text('Dernières ventes'));

    expect(find.text('Dernières ventes'), findsOneWidget);
    expect(find.text('Aminata Traoré'), findsOneWidget);
  });

  testWidgets('le dashboard affiche les deux actions principales', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    await scrollDashboardTo(tester, find.text('NOUVELLE VENTE'));

    expect(find.text('NOUVELLE VENTE'), findsOneWidget);

    await scrollDashboardTo(tester, find.text('NOUVEL ARRIVAGE'));

    expect(find.text('NOUVEL ARRIVAGE'), findsWidgets);
  });
}
