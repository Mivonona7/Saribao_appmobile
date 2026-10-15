import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../datasources/payment_local_datasource.dart';
import '../datasources/sale_local_datasource.dart';
import '../datasources/stock_local_datasource.dart';
import '../models/payment.dart';
import '../models/sale.dart';
import '../models/stock_movement.dart';

/// Résultat de l'enregistrement d'une vente.
class SaleResult {
  const SaleResult({required this.saleId, required this.stockAfter});

  /// Identifiant de la vente créée.
  final int saleId;

  /// Stock restant après la vente.
  final int stockAfter;
}

/// Repository ventes : le cœur métier de l'application.
///
/// L'enregistrement est atomique (transaction SQLite) :
/// vérification du stock, création de la vente, mouvement de stock.
/// Si une étape échoue, rien n'est écrit.
class SaleRepository {
  const SaleRepository(
    this._appDatabase,
    this._saleDataSource,
    this._stockDataSource,
    this._paymentDataSource,
  );

  final AppDatabase _appDatabase;
  final SaleLocalDataSource _saleDataSource;
  final StockLocalDataSource _stockDataSource;
  final PaymentLocalDataSource _paymentDataSource;

  /// Vérifie la saisie d'une vente.
  ///
  /// - quantité >= 1
  /// - prix unitaire > 0
  /// - montant payé dans [0, total]
  static void validate({
    required int quantity,
    required int unitPrice,
    required int paidAmount,
  }) {
    if (quantity < 1) {
      throw const ValidationException(
        'Le nombre de sacs doit être supérieur à 0.',
      );
    }
    if (unitPrice <= 0) {
      throw const ValidationException(
        'Le prix par sac doit être supérieur à 0.',
      );
    }
    if (paidAmount < 0) {
      throw const ValidationException(
        'Le montant payé ne peut pas être négatif.',
      );
    }
    final int total = Sale.calculateTotal(quantity, unitPrice);
    if (paidAmount > total) {
      throw ValidationException(
        'Le montant payé ($paidAmount Ar) ne peut pas dépasser '
        'le total de la vente ($total Ar).',
      );
    }
  }

  /// Calcule le total d'une vente sans l'enregistrer.
  static int computeTotal(int quantity, int unitPrice) =>
      Sale.calculateTotal(quantity, unitPrice);

  /// Calcule le crédit d'une vente sans l'enregistrer.
  static int computeCredit(int quantity, int unitPrice, int paidAmount) =>
      Sale.calculateCredit(computeTotal(quantity, unitPrice), paidAmount);

  /// Stock disponible avant toute écriture.
  Future<int> getAvailableStock() => _stockDataSource.getCurrentStock(null);

  /// Enregistre une vente et décrémente le stock, en une seule transaction.
  Future<SaleResult> createSale({
    int? clientId,
    required int quantity,
    required int unitPrice,
    required int paidAmount,
    String? note,
  }) async {
    validate(
      quantity: quantity,
      unitPrice: unitPrice,
      paidAmount: paidAmount,
    );

    if (paidAmount > 0 && clientId == null) {
      throw const ValidationException(
        'Choisissez un client pour enregistrer un paiement.',
      );
    }

    final int total = computeTotal(quantity, unitPrice);
    final int credit = Sale.calculateCredit(total, paidAmount);
    final String status = Sale.resolveStatus(total, paidAmount);

    return _inTransaction((Transaction txn) async {
      // 1. Vérifier le stock avant toute écriture.
      final int available = await _stockDataSource.getCurrentStock(txn);
      if (available < quantity) {
        throw InsufficientStockException(
          available: available,
          requested: quantity,
        );
      }

      // 2. Créer la vente.
      final int saleId = await _saleDataSource.insert(
        Sale(
          clientId: clientId,
          quantity: quantity,
          unitPrice: unitPrice,
          totalAmount: total,
          paidAmount: paidAmount,
          creditAmount: credit,
          paymentStatus: status,
          note: (note != null && note.trim().isNotEmpty) ? note.trim() : null,
        ),
        txn,
      );

      // 3. Enregistrer le paiement initial s'il y en a un.
      if (paidAmount > 0) {
        await _paymentDataSource.insert(
          Payment(
            clientId: clientId!,
            saleId: saleId,
            amount: paidAmount,
          ),
          txn,
        );
      }

      // 4. Enregistrer le mouvement de stock correspondant.
      final int stockAfter = available - quantity;
      await _stockDataSource.insertMovement(
        StockMovement(
          movementType: MovementType.sale,
          quantity: -quantity,
          referenceType: 'sale',
          referenceId: saleId,
          label: 'Vente de $quantity sacs',
          stockAfter: stockAfter,
        ),
        txn,
      );

      return SaleResult(saleId: saleId, stockAfter: stockAfter);
    });
  }

  /// Vente par identifiant, `null` si absente.
  Future<Sale?> getById(int id) => _saleDataSource.getById(id);

  /// Ventes paginées avec le nom du client.
  Future<List<Sale>> getAll({int limit = 100, int offset = 0}) =>
      _saleDataSource.getAll(limit: limit, offset: offset);

  /// Ventes d'un client.
  Future<List<Sale>> getByClient(int clientId, {int limit = 200}) =>
      _saleDataSource.getByClient(clientId, limit: limit);

  /// Agrégats de ventes sur une période.
  Future<SaleSummary> getSummary({
    required DateTime from,
    required DateTime to,
  }) => _saleDataSource.getSummary(from: from, to: to);

  /// Nombre total de ventes.
  Future<int> countAll() => _saleDataSource.countAll();

  /// Dernières ventes, pour le dashboard.
  Future<List<Sale>> getRecent({int limit = 5}) =>
      _saleDataSource.getAll(limit: limit);

  /// Exécute [action] dans une transaction SQLite : commit ou rollback.
  Future<T> _inTransaction<T>(Future<T> Function(Transaction txn) action) {
    return _appDatabase.transaction<T>(action);
  }
}