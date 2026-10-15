import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/sale.dart';

/// Accès SQLite aux ventes.
class SaleLocalDataSource {
  const SaleLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// Insère une vente dans la transaction courante.
  Future<int> insert(Sale sale, Transaction txn) async {
    final DateTime now = DateTime.now();
    return txn.insert(DbTables.sales, <String, Object?>{
      DbColumns.clientId: sale.clientId,
      DbColumns.quantity: sale.quantity,
      DbColumns.unitPrice: sale.unitPrice,
      DbColumns.totalAmount: sale.totalAmount,
      DbColumns.paidAmount: sale.paidAmount,
      DbColumns.creditAmount: sale.creditAmount,
      DbColumns.paymentStatus: sale.paymentStatus,
      DbColumns.note: sale.note,
      DbColumns.createdAt: (sale.createdAt ?? now).toIso8601String(),
      DbColumns.updatedAt: (sale.updatedAt ?? now).toIso8601String(),
    });
  }

  /// Ventes paginées avec le nom du client joint, pour l'historique.
  Future<List<Sale>> getAll({int limit = 100, int offset = 0}) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT s.*, c.${DbColumns.name} AS client_name
      FROM ${DbTables.sales} s
      LEFT JOIN ${DbTables.clients} c ON c.${DbColumns.id} = s.${DbColumns.clientId}
      ORDER BY s.${DbColumns.createdAt} DESC, s.${DbColumns.id} DESC
      LIMIT ? OFFSET ?
      ''',
      <Object?>[limit, offset],
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  /// Vente par identifiant, `null` si absente.
  Future<Sale?> getById(int id) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT s.*, c.${DbColumns.name} AS client_name
      FROM ${DbTables.sales} s
      LEFT JOIN ${DbTables.clients} c ON c.${DbColumns.id} = s.${DbColumns.clientId}
      WHERE s.${DbColumns.id} = ?
      LIMIT 1
      ''',
      <Object?>[id],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// Ventes d'un client, de la plus récente à la plus ancienne.
  Future<List<Sale>> getByClient(int clientId, {int limit = 200}) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT s.*, c.${DbColumns.name} AS client_name
      FROM ${DbTables.sales} s
      LEFT JOIN ${DbTables.clients} c ON c.${DbColumns.id} = s.${DbColumns.clientId}
      WHERE s.${DbColumns.clientId} = ?
      ORDER BY s.${DbColumns.createdAt} DESC, s.${DbColumns.id} DESC
      LIMIT ?
      ''',
      <Object?>[clientId, limit],
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Sale _fromRow(Map<String, Object?> row) {
    return Sale(
      id: row[DbColumns.id] as int?,
      clientId: row[DbColumns.clientId] as int?,
      quantity: (row[DbColumns.quantity] as num).toInt(),
      unitPrice: (row[DbColumns.unitPrice] as num).toInt(),
      totalAmount: (row[DbColumns.totalAmount] as num).toInt(),
      paidAmount: (row[DbColumns.paidAmount] as num).toInt(),
      creditAmount: (row[DbColumns.creditAmount] as num).toInt(),
      paymentStatus: row[DbColumns.paymentStatus] as String,
      note: row[DbColumns.note] as String?,
      createdAt: DateTime.tryParse(row[DbColumns.createdAt] as String? ?? ''),
      updatedAt: DateTime.tryParse(row[DbColumns.updatedAt] as String? ?? ''),
    );
  }

  /// Agrégats de ventes sur une période : sacs vendus, chiffre d'affaires,
  /// encaissements et crédits ouverts.
  Future<SaleSummary> getSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT
        COALESCE(SUM(${DbColumns.quantity}), 0) AS bags,
        COALESCE(SUM(${DbColumns.totalAmount}), 0) AS revenue,
        COALESCE(SUM(${DbColumns.paidAmount}), 0) AS collected,
        COALESCE(SUM(${DbColumns.creditAmount}), 0) AS credit
      FROM ${DbTables.sales}
      WHERE ${DbColumns.createdAt} >= ? AND ${DbColumns.createdAt} <= ?
      ''',
      <Object?>[from.toIso8601String(), to.toIso8601String()],
    );

    final Map<String, Object?> row = rows.first;
    return SaleSummary(
      bagsSold: (row['bags'] as num?)?.toInt() ?? 0,
      revenue: (row['revenue'] as num?)?.toInt() ?? 0,
      collected: (row['collected'] as num?)?.toInt() ?? 0,
      credit: (row['credit'] as num?)?.toInt() ?? 0,
    );
  }

  /// Nombre total de ventes (toutes périodes).
  Future<int> countAll() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${DbTables.sales}',
    );
    return (rows.first['c'] as num?)?.toInt() ?? 0;
  }
}

/// Agrégats de ventes calculés par SQLite.
class SaleSummary {
  const SaleSummary({
    required this.bagsSold,
    required this.revenue,
    required this.collected,
    required this.credit,
  });

  /// Sacs vendus sur la période.
  final int bagsSold;

  /// Chiffre d'affaires de la période.
  final int revenue;

  /// Montant encaissé à la vente sur la période.
  final int collected;

  /// Crédits ouverts sur la période.
  final int credit;
}