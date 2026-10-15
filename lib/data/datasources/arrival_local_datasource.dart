import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/arrival.dart';

/// Accès SQLite aux arrivages.
class ArrivalLocalDataSource {
  const ArrivalLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// Insère un arrivage dans la transaction courante.
  Future<int> insert(Arrival arrival, Transaction txn) async {
    return txn.insert(DbTables.arrivals, <String, Object?>{
      DbColumns.quantity: arrival.quantity,
      DbColumns.purchasePricePerBag: arrival.purchasePricePerBag,
      DbColumns.totalPurchaseAmount: arrival.totalPurchaseAmount,
      DbColumns.supplier: arrival.supplier,
      DbColumns.createdAt:
          (arrival.createdAt ?? DateTime.now()).toIso8601String(),
    });
  }

  /// Arrivages paginés, du plus récent au plus ancien.
  Future<List<Arrival>> getAll({int limit = 100, int offset = 0}) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.arrivals,
      orderBy: '${DbColumns.createdAt} DESC, ${DbColumns.id} DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Arrival _fromRow(Map<String, Object?> row) {
    return Arrival(
      id: row[DbColumns.id] as int?,
      quantity: (row[DbColumns.quantity] as num).toInt(),
      purchasePricePerBag:
          (row[DbColumns.purchasePricePerBag] as num).toInt(),
      totalPurchaseAmount:
          (row[DbColumns.totalPurchaseAmount] as num).toInt(),
      supplier: row[DbColumns.supplier] as String?,
      createdAt: DateTime.tryParse(row[DbColumns.createdAt] as String? ?? ''),
    );
  }

  /// Total des achats sur une période.
  Future<int> getTotalPurchase({
    required DateTime from,
    required DateTime to,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COALESCE(SUM(${DbColumns.totalPurchaseAmount}), 0) AS total '
      'FROM ${DbTables.arrivals} '
      'WHERE ${DbColumns.createdAt} >= ? AND ${DbColumns.createdAt} <= ?',
      <Object?>[from.toIso8601String(), to.toIso8601String()],
    );
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }
}