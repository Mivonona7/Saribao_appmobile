import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/core/l10n/app_strings.dart';
import 'package:saribao/data/models/app_settings.dart';

void main() {
  group('AppStrings', () {
    test('le français est la langue par défaut', () {
      expect(AppStrings.of(const Locale('fr')), same(AppStrings.french));
    });

    test('les anciennes locales et locales inconnues retombent sur le français', () {
      expect(AppStrings.of(const Locale('mg')), same(AppStrings.french));
      expect(AppStrings.of(const Locale('de')), same(AppStrings.french));
    });

    test('les libellés français ne sont pas vides', () {
      for (final String key in <String>[
        'nav.home',
        'nav.stock',
        'nav.sales',
        'nav.clients',
        'settings.title',
        'settings.appearance',
        'about.developerName',
      ]) {
        final String value = AppStrings.french.t(key);
        expect(value, isNotEmpty, reason: '$key vide en français');
        expect(value, isNot(equals(key)), reason: '$key absente en français');
      }
    });

    test('les libellés métier restent corrects', () {
      expect(AppStrings.french.t('nav.stock'), 'Stock');
      expect(AppStrings.french.t('about.developerName'), 'Andry RAMANANTSOA');
    });

    test('une clé absente renvoie la clé pour rester identifiable', () {
      expect(AppStrings.french.t('cle.inconnue'), 'cle.inconnue');
    });

    test('withArgs interpole les valeurs', () {
      expect(
        AppStrings.french.withArgs('common.sacsCount', <String, String>{
          'count': '82',
        }),
        '82 sacs',
      );
    });

    test('seul le français est déclaré comme locale prise en charge', () {
      for (final Locale locale in AppStrings.supportedLocales) {
        expect(AppStrings.delegate.isSupported(locale), isTrue);
      }
      expect(AppStrings.delegate.isSupported(const Locale('mg')), isFalse);
      expect(AppStrings.supportedLocales, <Locale>[const Locale('fr')]);
      expect(AppLanguage.values, <AppLanguage>[
        AppLanguage.french,
      ]);
    });
  });

  group('AppLanguage', () {
    test('fromCode résout les codes connus', () {
      expect(AppLanguage.fromCode('fr'), AppLanguage.french);
      expect(AppLanguage.fromCode('mg'), AppLanguage.french);
    });

    test('fromCode retombe sur le français pour une valeur absente', () {
      expect(AppLanguage.fromCode(null), AppLanguage.french);
      expect(AppLanguage.fromCode('en'), AppLanguage.french);
      expect(AppLanguage.fromCode(''), AppLanguage.french);
    });

    test('chaque langue expose sa locale et son badge', () {
      expect(AppLanguage.french.locale, const Locale('fr'));
      expect(AppLanguage.french.badge, 'FR');
    });
  });

  group('AppThemeModeSetting', () {
    test('fromCode résout les trois modes', () {
      expect(
        AppThemeModeSetting.fromCode('system'),
        AppThemeModeSetting.system,
      );
      expect(AppThemeModeSetting.fromCode('light'), AppThemeModeSetting.light);
      expect(AppThemeModeSetting.fromCode('dark'), AppThemeModeSetting.dark);
    });

    test('fromCode retombe sur system pour une valeur absente', () {
      expect(AppThemeModeSetting.fromCode(null), AppThemeModeSetting.system);
      expect(AppThemeModeSetting.fromCode('sepia'), AppThemeModeSetting.system);
    });

    test('chaque mode mappe vers le ThemeMode attendu', () {
      expect(AppThemeModeSetting.system.themeMode, ThemeMode.system);
      expect(AppThemeModeSetting.light.themeMode, ThemeMode.light);
      expect(AppThemeModeSetting.dark.themeMode, ThemeMode.dark);
    });
  });

  group('AppSettings', () {
    test('les valeurs par défaut suivent le système et le français', () {
      const AppSettings defaults = AppSettings.defaults;
      expect(defaults.themeMode, AppThemeModeSetting.system);
      expect(defaults.language, AppLanguage.french);
    });

    test('copyWith ne modifie que le champ demandé', () {
      const AppSettings base = AppSettings();
      final AppSettings dark = base.copyWith(
        themeMode: AppThemeModeSetting.dark,
      );

      expect(dark.themeMode, AppThemeModeSetting.dark);
      expect(dark.language, AppLanguage.french);
    });

    test('copyWith sans argument conserve tout', () {
      const AppSettings base = AppSettings(
        themeMode: AppThemeModeSetting.dark,
        language: AppLanguage.french,
      );
      expect(base.copyWith(), base);
    });

    test('deux réglages identiques sont égaux', () {
      const AppSettings a = AppSettings(
        themeMode: AppThemeModeSetting.dark,
        language: AppLanguage.french,
      );
      const AppSettings b = AppSettings(
        themeMode: AppThemeModeSetting.dark,
        language: AppLanguage.french,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const AppSettings()));
    });
  });
}