import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';
import '../viewmodels/base_view_model.dart';

/// ViewModel des paramètres : apparence et langue.
///
/// Source de vérité unique pour `MaterialApp` : il expose [themeMode] et
/// [locale], et notifie dès qu'une préférence change. Les écritures sont
/// tolérantes — un échec de persistance ne doit pas bloquer l'affichage, le
/// choix reste valable pour la session en cours.
class SettingsViewModel extends BaseViewModel {
  SettingsViewModel({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  AppSettings _settings = AppSettings.defaults;

  /// Préférences actives.
  AppSettings get settings => _settings;

  /// Mode d'apparence à fournir à `MaterialApp.themeMode`.
  ThemeMode get themeMode => _settings.themeMode.themeMode;

  /// Locale à fournir à `MaterialApp.locale`.
  Locale get locale => _settings.language.locale;

  /// Langue active.
  AppLanguage get language => _settings.language;

  /// Charge les préférences enregistrées.
  Future<void> load() async {
    try {
      _settings = await _settingsRepository.load();
    } catch (error) {
      // Sans préférences lisibles, les valeurs par défaut restent valables.
      _settings = AppSettings.defaults;
    }
    safeNotify();
  }

  /// Change et enregistre le mode d'apparence.
  Future<void> setThemeMode(AppThemeModeSetting setting) async {
    if (_settings.themeMode == setting) return;

    _settings = _settings.copyWith(themeMode: setting);
    safeNotify();

    try {
      await _settingsRepository.saveThemeMode(setting);
    } catch (error) {
      setError(describeError(error));
    }
  }

  /// Change et enregistre la langue.
  Future<void> setLanguage(AppLanguage language) async {
    if (_settings.language == language) return;

    _settings = _settings.copyWith(language: language);
    safeNotify();

    try {
      await _settingsRepository.saveLanguage(language);
    } catch (error) {
      setError(describeError(error));
    }
  }
}