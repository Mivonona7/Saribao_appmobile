import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/data/models/app_settings.dart';
import 'package:saribao/data/repositories/settings_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabase harness;
  late SettingsRepository repository;

  setUp(() async {
    harness = await TestDatabase.create();
    repository = harness.dependencies.settingsRepository;
  });

  tearDown(() => TestDatabase.tearDown());

  group('SettingsRepository', () {
    test('une base neuve renvoie les valeurs par défaut', () async {
      final AppSettings settings = await repository.load();

      expect(settings.themeMode, AppThemeModeSetting.system);
      expect(settings.language, AppLanguage.french);
      expect(settings, AppSettings.defaults);
    });

    test('le mode d\'apparence est persisté', () async {
      await repository.saveThemeMode(AppThemeModeSetting.dark);

      expect(
        (await repository.load()).themeMode,
        AppThemeModeSetting.dark,
      );
    });

    test('le français est persisté comme seule langue disponible', () async {
      await repository.saveLanguage(AppLanguage.french);

      expect((await repository.load()).language, AppLanguage.french);
    });

    test('les préférences sont persistées ensemble', () async {
      await repository.saveThemeMode(AppThemeModeSetting.light);
      await repository.saveLanguage(AppLanguage.french);

      final AppSettings settings = await repository.load();

      expect(settings.themeMode, AppThemeModeSetting.light);
      expect(settings.language, AppLanguage.french);
    });

    test('réécrire une clé remplace la valeur précédente', () async {
      await repository.saveThemeMode(AppThemeModeSetting.dark);
      await repository.saveThemeMode(AppThemeModeSetting.light);

      expect(
        (await repository.load()).themeMode,
        AppThemeModeSetting.light,
      );
    });

    test('changer la langue ne touche pas l\'apparence', () async {
      await repository.saveThemeMode(AppThemeModeSetting.dark);
      await repository.saveLanguage(AppLanguage.french);

      final AppSettings settings = await repository.load();

      expect(settings.themeMode, AppThemeModeSetting.dark);
      expect(settings.language, AppLanguage.french);
    });

    test('les valeurs restent disponibles après une nouvelle lecture', () async {
      await repository.saveThemeMode(AppThemeModeSetting.dark);
      await repository.saveLanguage(AppLanguage.french);

      final AppSettings first = await repository.load();
      final AppSettings second = await repository.load();

      expect(second, first);
    });
  });
}
