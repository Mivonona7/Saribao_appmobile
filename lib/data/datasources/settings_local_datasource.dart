import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';

/// Accès SQLite à la table `settings`.
///
/// Les préférences sont stockées en clé/valeur textuelles : le même schéma
/// accueille des réglages futurs (notifications, nom du commerce, format de
/// date) sans migration tant que le volume reste faible.
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// Lit une valeur, ou `null` si la clé n'a jamais été écrite.
  Future<String?> read(String key) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.settings,
      columns: <String>[DbColumns.value],
      where: '${DbColumns.key} = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[DbColumns.value] as String?;
  }

  /// Écrit une valeur, en remplaçant l'éventuelle valeur précédente.
  Future<void> write(String key, String value) async {
    final Database db = await _db;
    await db.insert(DbTables.settings, <String, Object?>{
      DbColumns.key: key,
      DbColumns.value: value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Toutes les préférences sous forme de table clé/valeur.
  Future<Map<String, String>> readAll() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(DbTables.settings);
    return <String, String>{
      for (final Map<String, Object?> row in rows)
        row[DbColumns.key]! as String: row[DbColumns.value]! as String,
    };
  }
}