import '../datasources/settings_local_datasource.dart';
import '../models/app_settings.dart';

/// Lecture et écriture des préférences utilisateur.
///
/// Isolé derrière une interface pour que les tests puissent injecter un
/// double, et pour que la couche présentation ignore l'existence de SQLite.
class SettingsRepository {
  const SettingsRepository(this._dataSource);

  /// Clé du mode d'apparence.
  static const String keyThemeMode = 'theme_mode';

  /// Clé de la langue de l'interface.
  static const String keyLanguage = 'language';

  final SettingsLocalDataSource _dataSource;

  /// Préférences actuellement enregistrées.
  ///
  /// Renvoie [AppSettings.defaults] si rien n'a encore été écrit, ce qui est le
  /// cas à la première exécution.
  Future<AppSettings> load() async {
    final Map<String, String> values = await _dataSource.readAll();
    return AppSettings(
      themeMode: AppThemeModeSetting.fromCode(values[keyThemeMode]),
      language: AppLanguage.fromCode(values[keyLanguage]),
    );
  }

  /// Enregistre le mode d'apparence choisi.
  Future<void> saveThemeMode(AppThemeModeSetting setting) {
    return _dataSource.write(keyThemeMode, setting.code);
  }

  /// Enregistre la langue choisie.
  Future<void> saveLanguage(AppLanguage language) {
    return _dataSource.write(keyLanguage, language.code);
  }
}