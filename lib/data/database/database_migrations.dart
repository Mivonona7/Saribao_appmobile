import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

/// Schéma de création et migrations de la base locale.
///
/// Le stock n'est jamais stocké dans une colonne : il est toujours recalculé
/// à partir de la somme des `stock_movements`. Une seule source de vérité,
/// donc aucune incohérence possible entre « stock affiché » et « historique ».
abstract final class DatabaseMigrations {
  /// Crée le schéma initial.
  static Future<void> createV1(Database db) async {
    await db.execute('''
      CREATE TABLE ${DbTables.clients} (
        ${DbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbColumns.name} TEXT NOT NULL,
        ${DbColumns.phone} TEXT,
        ${DbColumns.address} TEXT,
        ${DbColumns.createdAt} TEXT NOT NULL,
        ${DbColumns.updatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbTables.sales} (
        ${DbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbColumns.clientId} INTEGER,
        ${DbColumns.quantity} INTEGER NOT NULL,
        ${DbColumns.unitPrice} INTEGER NOT NULL,
        ${DbColumns.totalAmount} INTEGER NOT NULL,
        ${DbColumns.paidAmount} INTEGER NOT NULL DEFAULT 0,
        ${DbColumns.creditAmount} INTEGER NOT NULL DEFAULT 0,
        ${DbColumns.paymentStatus} TEXT NOT NULL,
        ${DbColumns.note} TEXT,
        ${DbColumns.createdAt} TEXT NOT NULL,
        ${DbColumns.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbColumns.clientId})
          REFERENCES ${DbTables.clients} (${DbColumns.id})
          ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbTables.saleItems} (
        ${DbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbColumns.saleId} INTEGER NOT NULL,
        ${DbColumns.quantity} INTEGER NOT NULL,
        ${DbColumns.unitPrice} INTEGER NOT NULL,
        ${DbColumns.totalAmount} INTEGER NOT NULL,
        FOREIGN KEY (${DbColumns.saleId})
          REFERENCES ${DbTables.sales} (${DbColumns.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbTables.arrivals} (
        ${DbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbColumns.quantity} INTEGER NOT NULL,
        ${DbColumns.purchasePricePerBag} INTEGER NOT NULL,
        ${DbColumns.totalPurchaseAmount} INTEGER NOT NULL,
        ${DbColumns.supplier} TEXT,
        ${DbColumns.createdAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbTables.payments} (
        ${DbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbColumns.clientId} INTEGER NOT NULL,
        ${DbColumns.saleId} INTEGER,
        ${DbColumns.amount} INTEGER NOT NULL,
        ${DbColumns.createdAt} TEXT NOT NULL,
        FOREIGN KEY (${DbColumns.clientId})
          REFERENCES ${DbTables.clients} (${DbColumns.id})
          ON DELETE RESTRICT,
        FOREIGN KEY (${DbColumns.saleId})
          REFERENCES ${DbTables.sales} (${DbColumns.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbTables.stockMovements} (
        ${DbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbColumns.movementType} TEXT NOT NULL,
        ${DbColumns.quantity} INTEGER NOT NULL,
        ${DbColumns.referenceType} TEXT,
        ${DbColumns.referenceId} INTEGER,
        ${DbColumns.label} TEXT,
        ${DbColumns.stockAfter} INTEGER NOT NULL,
        ${DbColumns.createdAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbTables.settings} (
        ${DbColumns.key} TEXT PRIMARY KEY,
        ${DbColumns.value} TEXT NOT NULL
      )
    ''');

    await _createIndexes(db);
  }

  /// Index utilisés par les requêtes fréquentes (historique, crédits, recherche).
  static Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_sales_created ON ${DbTables.sales} '
      '(${DbColumns.createdAt})',
    );
    await db.execute(
      'CREATE INDEX idx_sales_client ON ${DbTables.sales} '
      '(${DbColumns.clientId})',
    );
    await db.execute(
      'CREATE INDEX idx_payments_client ON ${DbTables.payments} '
      '(${DbColumns.clientId})',
    );
    await db.execute(
      'CREATE INDEX idx_payments_sale ON ${DbTables.payments} '
      '(${DbColumns.saleId})',
    );
    await db.execute(
      'CREATE INDEX idx_movements_created ON ${DbTables.stockMovements} '
      '(${DbColumns.createdAt})',
    );
  }
}