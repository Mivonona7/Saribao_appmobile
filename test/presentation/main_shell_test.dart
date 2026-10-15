import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/presentation/dashboard/main_shell.dart';
import 'package:saribao/presentation/clients/clients_screen.dart';
import 'package:saribao/presentation/sales/sales_screen.dart';
import 'package:saribao/presentation/stock/stock_screen.dart';

import '../helpers/app_harness.dart';

void main() {
  testWidgets('la barre d\'onglets expose les 4 sections', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Ventes'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
  });

  testWidgets('changer d\'onglet affiche l\'écran correspondant', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    await tester.tap(find.text('Clients'));
    await tester.pumpAndSettle();

    expect(find.byType(ClientsScreen), findsOneWidget);
    expect(find.text('Aminata Traoré'), findsOneWidget);

    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();

    expect(find.byType(StockScreen), findsOneWidget);
  });

  testWidgets('l\'onglet ventes affiche les ventes de la base', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    await tester.tap(find.text('Ventes'));
    await tester.pumpAndSettle();

    expect(find.byType(SalesScreen), findsOneWidget);
    expect(find.text('Aminata Traoré'), findsOneWidget);
  });

  testWidgets('le dashboard reste visible après aller-retour entre onglets', (
    WidgetTester tester,
  ) async {
    await pumpSaribaoApp(tester);

    await tester.tap(find.text('Ventes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();

    expect(find.text('STOCK DISPONIBLE'), findsOneWidget);
    expect(find.text('$seededStock'), findsOneWidget);
  });
}
