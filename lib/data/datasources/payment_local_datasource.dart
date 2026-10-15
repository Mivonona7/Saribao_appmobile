import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/payment.dart';

/// Accès SQLite aux paiements et aux crédits clients.
class PaymentLocalDataSource {
  const PaymentLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// Insère un paiement dans la transaction courante.
  Future<int> insert(Payment payment, Transaction txn) async {
    return txn.insert(DbTables.payments, <String, Object?>{
      DbColumns.clientId: payment.clientId,
      DbColumns.saleId: payment.saleId,
      DbColumns.amount: payment.amount,
      DbColumns.createdAt:
          (payment.createdAt ?? DateTime.now()).toIso8601String(),
    });
  }

  /// Paiements d'un client, du plus récent au plus ancien.
  Future<List<Payment>> getByClient(int clientId, {int limit = 200}) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.payments,
      where: '${DbColumns.clientId} = ?',
      whereArgs: <Object?>[clientId],
      orderBy: '${DbColumns.createdAt} DESC, ${DbColumns.id} DESC',
      limit: limit,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  /// Paiements imputés sur une vente précise.
  Future<List<Payment>> getBySale(int saleId) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      DbTables.payments,
      where: '${DbColumns.saleId} = ?',
      whereArgs: <Object?>[saleId],
      orderBy: '${DbColumns.createdAt} DESC, ${DbColumns.id} DESC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Payment _fromRow(Map<String, Object?> row) {
    return Payment(
      id: row[DbColumns.id] as int?,
      clientId: (row[DbColumns.clientId] as num).toInt(),
      saleId: row[DbColumns.saleId] as int?,
      amount: (row[DbColumns.amount] as num).toInt(),
      createdAt: DateTime.tryParse(row[DbColumns.createdAt] as String? ?? ''),
    );
  }

  /// Crédit restant d'un client.
  ///
  /// Formule unique : `somme des ventes - somme des paiements`. On n'utilise
  /// volontairement pas `sales.credit_amount`, car celui-ci est déjà net du
  /// paiement effectué lors de la vente : le soustraire à nouveau compterait
  /// deux fois l'acompte et afficherait un crédit faux.
  Future<int> getClientCredit(int clientId) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT
        COALESCE((SELECT SUM(${DbColumns.totalAmount}) FROM ${DbTables.sales}
                  WHERE ${DbColumns.clientId} = ?), 0)
        - COALESCE((SELECT SUM(${DbColumns.amount}) FROM ${DbTables.payments}
                    WHERE ${DbColumns.clientId} = ?), 0) AS credit
      ''',
      <Object?>[clientId, clientId],
    );
    final int credit = (rows.first['credit'] as num?)?.toInt() ?? 0;
    return credit < 0 ? 0 : credit;
  }

  /// Clients endettés, du plus gros crédit au plus petit.
  ///
  /// Renvoie `id`, `name` et le crédit restant, sans charger toutes les ventes.
  Future<List<ClientCredit>> getClientsWithCredit({int limit = 200}) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT * FROM (
        SELECT
          c.${DbColumns.id} AS client_id,
          c.${DbColumns.name} AS name,
          COALESCE((SELECT SUM(s.${DbColumns.totalAmount}) FROM ${DbTables.sales} s
                    WHERE s.${DbColumns.clientId} = c.${DbColumns.id}), 0)
          - COALESCE((SELECT SUM(p.${DbColumns.amount}) FROM ${DbTables.payments} p
                      WHERE p.${DbColumns.clientId} = c.${DbColumns.id}), 0)
            AS credit
        FROM ${DbTables.clients} c
      ) WHERE credit > 0
      ORDER BY credit DESC
      LIMIT ?
      ''',
      <Object?>[limit],
    );

    return rows
        .map(
          (Map<String, Object?> row) => ClientCredit(
            clientId: (row['client_id'] as num).toInt(),
            name: row['name'] as String,
            credit: (row['credit'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList(growable: false);
  }

  /// Total des crédits ouverts, tous clients confondus.
  Future<int> getTotalOutstandingCredit() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT
        COALESCE((SELECT SUM(${DbColumns.totalAmount}) FROM ${DbTables.sales}), 0)
        - COALESCE((SELECT SUM(${DbColumns.amount}) FROM ${DbTables.payments}), 0)
          AS credit
      ''',
    );
    final int credit = (rows.first['credit'] as num?)?.toInt() ?? 0;
    return credit < 0 ? 0 : credit;
  }

  /// Met à jour le crédit et le statut d'une vente après un paiement imputé.
  Future<void> applyToSale(
    Transaction txn,
    int saleId,
    int paidAmount,
  ) async {
    final List<Map<String, Object?>> rows = await txn.rawQuery(
      'SELECT ${DbColumns.totalAmount} FROM ${DbTables.sales} '
      'WHERE ${DbColumns.id} = ?',
      <Object?>[saleId],
    );
    if (rows.isEmpty) return;

    final int total = (rows.first[DbColumns.totalAmount] as num).toInt();
    final int credit = total - paidAmount;

    String status;
    if (paidAmount <= 0) {
      status = PaymentStatus.credit;
    } else if (paidAmount >= total) {
      status = PaymentStatus.paid;
    } else {
      status = PaymentStatus.partial;
    }

    await txn.update(
      DbTables.sales,
      <String, Object?>{
        DbColumns.paidAmount: paidAmount,
        DbColumns.creditAmount: credit,
        DbColumns.paymentStatus: status,
        DbColumns.updatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DbColumns.id} = ?',
      whereArgs: <Object?>[saleId],
    );
  }

  /// Somme des paiements déjà imputés sur une vente.
  Future<int> getSalePaidAmount(Transaction txn, int saleId) async {
    final List<Map<String, Object?>> rows = await txn.rawQuery(
      'SELECT COALESCE(SUM(${DbColumns.amount}), 0) AS total '
      'FROM ${DbTables.payments} WHERE ${DbColumns.saleId} = ?',
      <Object?>[saleId],
    );
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Somme des paiements d'un client, toutes ventes confondus.
  Future<int> getClientTotalPaid(int clientId) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COALESCE(SUM(${DbColumns.amount}), 0) AS total '
      'FROM ${DbTables.payments} WHERE ${DbColumns.clientId} = ?',
      <Object?>[clientId],
    );
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }
}

/// Crédit ouvert d'un client.
class ClientCredit {
  const ClientCredit({
    required this.clientId,
    required this.name,
    required this.credit,
  });

  /// Identifiant du client endetté.
  final int clientId;

  /// Nom du client.
  final String name;

  /// Montant restant dû, en ariary.
  final int credit;
}