import 'package:flutter/material.dart';

/// Langue unique disponible dans l'application.
enum AppLanguage {
  /// Français, langue de référence.
  french('fr', 'Français', 'FR', Locale('fr'));

  const AppLanguage(
    this.code,
    this.label,
    this.badge,
    this.locale,
  );

  /// Code stocké en base et utilisé par [AppStrings].
  final String code;

  /// Nom de la langue, dans cette langue.
  final String label;

  /// Code court affiché dans le sélecteur.
  final String badge;

  /// Locale fournie à `MaterialApp`.
  final Locale locale;

  /// Langue correspondant à [code], ou [french] si le code est inconnu.
  ///
  /// Le repli évite qu'une base migrée vers l'avant ne casse l'application.
  static AppLanguage fromCode(String? code) {
    for (final AppLanguage language in AppLanguage.values) {
      if (language.code == code) return language;
    }
    return AppLanguage.french;
  }
}

/// Modes d'apparence proposés dans les réglages.
enum AppThemeModeSetting {
  /// Suit le réglage du système.
  system('system', ThemeMode.system),

  /// Thème clair, quelle que soit la configuration du système.
  light('light', ThemeMode.light),

  /// Thème sombre, quelle que soit la configuration du système.
  dark('dark', ThemeMode.dark);

  const AppThemeModeSetting(this.code, this.themeMode);

  /// Valeur stockée en base.
  final String code;

  /// Mode correspondant pour `MaterialApp`.
  final ThemeMode themeMode;

  /// Mode correspondant à [code], ou [system] si le code est inconnu.
  static AppThemeModeSetting fromCode(String? code) {
    for (final AppThemeModeSetting setting in AppThemeModeSetting.values) {
      if (setting.code == code) return setting;
    }
    return AppThemeModeSetting.system;
  }
}

/// Préférences persistées de l'utilisateur.
///
/// Objet unique contenant tout ce que la couche présentation doit savoir des
/// réglages : le mode d'apparence et la langue.
class AppSettings {
  /// Construit les préférences.
  const AppSettings({
    this.themeMode = AppThemeModeSetting.system,
    this.language = AppLanguage.french,
  });

  /// Préférences par défaut, appliquées à une installation neuve.
  static const AppSettings defaults = AppSettings();

  /// Mode d'apparence choisi par l'utilisateur.
  final AppThemeModeSetting themeMode;

  /// Langue choisie par l'utilisateur.
  final AppLanguage language;

  /// Copie avec les champs remplacés.
  AppSettings copyWith({
    AppThemeModeSetting? themeMode,
    AppLanguage? language,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(themeMode, language);
}