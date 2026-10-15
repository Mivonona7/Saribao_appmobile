import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/stock_movement.dart';

/// Accès SQLite aux mouvements de stock.
///
/// Le stock courant n'est jamais stocké : il se calcule par somme des
/// quantités signées. Une seule source de vérité.
class StockLocalDataSource {
  const StockLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// Stock actuel : somme des entrées moins sorties.
  Future<int> getCurrentStock(Transaction? txn) async {
    final List<Map<String, Object?>> rows = await (txn ?? await _db).rawQuery(
      'SELECT COALESCE(SUM(${DbColumns.quantity}), 0) AS total '
      'FROM ${DbTables.stockMovements}',
    );
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Insère un mouvement et renvoie son identifiant.
  Future<int> insertMovement(
    StockMovement movement,
    Transaction? txn,
  ) async {
    final Map<String, Object?> row = <String, Object?>{
      DbColumns.movementType: movement.movementType,
      DbColumns.quantity: movement.quantity,
      DbColumns.referenceType: movement.referenceType,
      DbColumns.referenceId: movement.referenceId,
      DbColumns.label: movement.label,
      DbColumns.stockAfter: movement.stockAfter,
      DbColumns.createdAt:
          (movement.createdAt ?? DateTime.now()).toIso8601String(),
    };
    return (txn ?? await _db).insert(DbTables.stockMovements, row);
  }

  /// Historique paginé des mouvements, du plus récent au plus ancien.
  Future<List<StockMovement>> getMovements({
    int limit = 100,
    int offset = 0,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.stockMovements,
      orderBy: '${DbColumns.createdAt} DESC, ${DbColumns.id} DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  StockMovement _fromRow(Map<String, Object?> row) {
    return StockMovement(
      id: row[DbColumns.id] as int?,
      movementType: row[DbColumns.movementType] as String,
      quantity: (row[DbColumns.quantity] as num).toInt(),
      referenceType: row[DbColumns.referenceType] as String?,
      referenceId: row[DbColumns.referenceId] as int?,
      label: row[DbColumns.label] as String?,
      stockAfter: (row[DbColumns.stockAfter] as num).toInt(),
      createdAt: DateTime.tryParse(row[DbColumns.createdAt] as String? ?? ''),
    );
  }
}