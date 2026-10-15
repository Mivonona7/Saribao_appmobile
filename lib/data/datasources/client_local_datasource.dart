import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/client.dart';

/// Accès SQLite aux clients.
class ClientLocalDataSource {
  const ClientLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  Map<String, Object?> _toRow(Client client, {required bool withId}) {
    final DateTime now = DateTime.now();
    return <String, Object?>{
      if (withId) DbColumns.id: client.id,
      DbColumns.name: client.name,
      DbColumns.phone: client.phone,
      DbColumns.address: client.address,
      DbColumns.createdAt: (client.createdAt ?? now).toIso8601String(),
      DbColumns.updatedAt: (client.updatedAt ?? now).toIso8601String(),
    };
  }

  Client _fromRow(Map<String, Object?> row) {
    return Client(
      id: row[DbColumns.id] as int?,
      name: row[DbColumns.name] as String,
      phone: row[DbColumns.phone] as String?,
      address: row[DbColumns.address] as String?,
      createdAt: DateTime.tryParse(row[DbColumns.createdAt] as String? ?? ''),
      updatedAt: DateTime.tryParse(row[DbColumns.updatedAt] as String? ?? ''),
    );
  }

  /// Tous les clients, par ordre alphabétique.
  Future<List<Client>> getAll() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.clients,
      orderBy: '${DbColumns.name} COLLATE NOCASE ASC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  /// Client par identifiant, `null` si absent.
  Future<Client?> getById(int id) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.clients,
      where: '${DbColumns.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// Recherche rapide par nom ou téléphone, limited pour les grands volumes.
  Future<List<Client>> search(String query, {int limit = 50}) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return getAll();

    final Database db = await _db;
    final String pattern = '%${trimmed.toLowerCase()}%';
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.clients,
      where:
          'LOWER(${DbColumns.name}) LIKE ? OR LOWER(${DbColumns.phone}) LIKE ?',
      whereArgs: <Object?>[pattern, pattern],
      orderBy: '${DbColumns.name} COLLATE NOCASE ASC',
      limit: limit,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  /// Insère un client et renvoie son identifiant.
  Future<int> insert(Client client) async {
    final Database db = await _db;
    return db.insert(
      DbTables.clients,
      _toRow(client, withId: false),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Met à jour un client existant.
  Future<int> update(Client client) async {
    final Database db = await _db;
    return db.update(
      DbTables.clients,
      _toRow(client.copyWith(updatedAt: DateTime.now()), withId: false),
      where: '${DbColumns.id} = ?',
      whereArgs: <Object?>[client.id],
    );
  }

  /// Supprime un client. Les clés étrangères empêchent la suppression s'il
  /// possède encore des ventes.
  Future<int> delete(int id) async {
    final Database db = await _db;
    return db.delete(
      DbTables.clients,
      where: '${DbColumns.id} = ?',
      whereArgs: <Object?>[id],
    );
  }
}