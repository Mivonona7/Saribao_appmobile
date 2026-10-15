import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../datasources/arrival_local_datasource.dart';
import '../datasources/stock_local_datasource.dart';
import '../models/arrival.dart';
import '../models/stock_movement.dart';

/// Résultat de l'enregistrement d'un arrivage.
class ArrivalResult {
  const ArrivalResult({
    required this.arrivalId,
    required this.stockAfter,
  });

  /// Identifiant de l'arrivage créé.
  final int arrivalId;

  /// Stock après ajout des sacs.
  final int stockAfter;
}

/// Repository arrivages : ajoute des sacs au stock, en une transaction.
class ArrivalRepository {
  const ArrivalRepository(
    this._appDatabase,
    this._arrivalDataSource,
    this._stockDataSource,
  );

  final AppDatabase _appDatabase;
  final ArrivalLocalDataSource _arrivalDataSource;
  final StockLocalDataSource _stockDataSource;

  /// Vérifie la saisie d'un arrivage.
  static void validate({
    required int quantity,
    required int purchasePricePerBag,
  }) {
    if (quantity < 1) {
      throw const ValidationException(
        'Le nombre de sacs doit être supérieur à 0.',
      );
    }
    if (purchasePricePerBag < 0) {
      throw const ValidationException(
        'Le prix d\'achat ne peut pas être négatif.',
      );
    }
  }

  /// Calcule le total d'achat.
  static int computeTotal(int quantity, int purchasePricePerBag) =>
      Arrival.calculateTotal(quantity, purchasePricePerBag);

  /// Enregistre un arrivage et incrémente le stock, en une transaction.
  Future<ArrivalResult> createArrival({
    required int quantity,
    required int purchasePricePerBag,
    String? supplier,
  }) async {
    validate(
      quantity: quantity,
      purchasePricePerBag: purchasePricePerBag,
    );

    final int total = computeTotal(quantity, purchasePricePerBag);

    return _appDatabase.transaction<ArrivalResult>((Transaction txn) async {
      final int available = await _stockDataSource.getCurrentStock(txn);

      // 1. Créer l'arrivage.
      final int arrivalId = await _arrivalDataSource.insert(
        Arrival(
          quantity: quantity,
          purchasePricePerBag: purchasePricePerBag,
          totalPurchaseAmount: total,
          supplier: (supplier != null && supplier.trim().isNotEmpty)
              ? supplier.trim()
              : null,
        ),
        txn,
      );

      // 2. Enregistrer le mouvement de stock correspondant.
      final int stockAfter = available + quantity;
      await _stockDataSource.insertMovement(
        StockMovement(
          movementType: MovementType.arrival,
          quantity: quantity,
          referenceType: 'arrival',
          referenceId: arrivalId,
          label: supplier == null || supplier.trim().isEmpty
              ? 'Arrivage de $quantity sacs'
              : 'Arrivage de $quantity sacs ($supplier)',
          stockAfter: stockAfter,
        ),
        txn,
      );

      return ArrivalResult(arrivalId: arrivalId, stockAfter: stockAfter);
    });
  }

  /// Arrivages paginés, du plus récent au plus ancien.
  Future<List<Arrival>> getAll({int limit = 100, int offset = 0}) =>
      _arrivalDataSource.getAll(limit: limit, offset: offset);

  /// Total des achats sur une période.
  Future<int> getTotalPurchase({
    required DateTime from,
    required DateTime to,
  }) => _arrivalDataSource.getTotalPurchase(from: from, to: to);
}