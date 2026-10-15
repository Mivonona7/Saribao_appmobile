import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/app/theme/app_palette.dart';
import 'package:saribao/data/models/app_settings.dart';
import 'package:saribao/presentation/settings/about_screen.dart';
import 'package:saribao/presentation/settings/settings_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/test_database.dart';

void main() {
/// Laisse l'interface se recalculer et les écritures SQLite se terminer.
///
/// Deux sbjets doivent avancer ensemble : le temps simulé (les animations et
/// le timer de sérialisation des transactions `sqflite`) et le temps réel
/// (l'appel FFI lui-même). D'où l'alternance `runAsync` / `pump`.
Future<void> pumpBounded(WidgetTester tester, {int cycles = 10}) async {
    for (int i = 0; i < cycles; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  /// Tape un élément puis laisse l'interface se recalculer.
  Future<void> tapText(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await pumpBounded(tester);
  }

  /// Ouvre l'écran des réglages depuis la barre d'action du dashboard.
  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await pumpBounded(tester);
  }

  /// Relit les préférences depuis SQLite.
  ///
  /// Toute lecture FFI doit passer par `runAsync` : hors de ce contexte, le
  /// futur ne se résout jamais car il dépend du temps réel.
  Future<AppSettings> readPersisted(WidgetTester tester, TestDatabase harness) async {
    final AppSettings? settings = await tester.runAsync(
      () => harness.dependencies.settingsRepository.load(),
    );
    if (settings == null) fail('Lecture des préférences impossible.');
    return settings;
  }

  group('apparence', () {
    testWidgets('le mode sombre assombrit les surfaces', (
      WidgetTester tester,
    ) async {
      await pumpSaribaoApp(tester, seed: false);

      await openSettings(tester);
      expect(find.text('Apparence'), findsOneWidget);

      await tapText(tester, 'Sombre');

      // Le thème sombre doit être actif sur l'écran courant.
      final BuildContext context = tester.element(find.byType(SettingsScreen));
      expect(context.appPalette.surface, AppPalette.dark.surface);
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('le mode clair reste disponible après un passage en sombre', (
      WidgetTester tester,
    ) async {
      await pumpSaribaoApp(tester, seed: false);

      await openSettings(tester);
      await tapText(tester, 'Sombre');
      await tapText(tester, 'Clair');

      final BuildContext context = tester.element(find.byType(SettingsScreen));
      expect(context.appPalette.surface, AppPalette.light.surface);
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('les trois modes d\'apparence sont proposés', (
      WidgetTester tester,
    ) async {
      await pumpSaribaoApp(tester, seed: false);
      await openSettings(tester);

      expect(find.text('Clair'), findsOneWidget);
      expect(find.text('Sombre'), findsOneWidget);
      expect(find.text('Automatique'), findsOneWidget);
    });

    testWidgets('le thème choisi est conservé en base', (
      WidgetTester tester,
    ) async {
      final TestDatabase harness = await pumpSaribaoApp(tester, seed: false);

      await openSettings(tester);
      await tapText(tester, 'Sombre');

      // La préférence doit être écrite sur le disque, pas seulement en mémoire.
      final AppSettings persisted = await readPersisted(tester, harness);
      expect(persisted.themeMode, AppThemeModeSetting.dark);
    });
  });

  group('écran à propos', () {
    testWidgets('l\'écran À propos crédite le développeur', (
      WidgetTester tester,
    ) async {
      await pumpSaribaoApp(tester, seed: false);

      await openSettings(tester);
      await tapText(tester, 'À propos');

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('Andry RAMANANTSOA'), findsOneWidget);
      expect(find.text('Développé par'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
    });

    testWidgets('la photo du développeur est embarquée', (
      WidgetTester tester,
    ) async {
      await pumpSaribaoApp(tester, seed: false);

      await openSettings(tester);
      await tapText(tester, 'À propos');

      final Iterable<String> assets = tester
          .widgetList<Image>(find.byType(Image))
          .map((Image image) => image.image)
          .whereType<AssetImage>()
          .map((AssetImage asset) => asset.assetName);

      expect(assets, contains(AboutScreen.developerPhotoAsset));
    });

    testWidgets('l\'écran À propos n\'utilise aucune image distante', (
      WidgetTester tester,
    ) async {
      await pumpSaribaoApp(tester, seed: false);

      await openSettings(tester);
      await tapText(tester, 'À propos');

      // Tout est dans le binaire : aucun `NetworkImage`.
      for (final Image image in tester.widgetList<Image>(find.byType(Image))) {
        expect(image.image, isA<AssetImage>());
      }
    });
  });

  group('charactères décoratifs', () {
    testWidgets('l\'accueil n\'a aucun emoji et affiche une icône', (
      WidgetTester tester,
    ) async {
      await pumpSaribaoApp(tester, seed: false);

      expect(find.byIcon(Icons.waving_hand_outlined), findsOneWidget);

      // Dart suit ECMAScript : un emoji est une paire de substituts, pas un
      // caractère hors du plan multilingue supplémentaire.
      final RegExp emoji = RegExp(r'[\uD83C-\uDBFF][\uDC00-\uDFFF]');
      final Iterable<String> labels = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text text) => text.data ?? '');
      expect(labels, everyElement(isNot(contains(emoji))));
    });
  });
}