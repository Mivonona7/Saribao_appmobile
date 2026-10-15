import '../../core/errors/app_exception.dart';
import '../datasources/stock_local_datasource.dart';
import '../models/stock_movement.dart';

/// Repository stock : lecture du stock et historique des mouvements.
///
/// Le stock n'est jamais une colonne : il est recalculé à partir des
/// mouvements, ce qui garantit qu'historique et stock ne peuvent pas diverger.
class StockRepository {
  const StockRepository(this._dataSource);

  final StockLocalDataSource _dataSource;

  /// Stock actuel en sacs.
  Future<int> getCurrentStock() => _dataSource.getCurrentStock(null);

  /// Historique paginé des mouvements, du plus récent au plus ancien.
  Future<List<StockMovement>> getMovements({
    int limit = 100,
    int offset = 0,
  }) => _dataSource.getMovements(limit: limit, offset: offset);

  /// Vérifie qu'une quantité peut être retirée du stock.
  static void validateCanRemove({required int available, required int quantity}) {
    if (quantity < 1) {
      throw const ValidationException(
        'Le nombre de sacs doit être supérieur à 0.',
      );
    }
    if (quantity > available) {
      throw InsufficientStockException(
        available: available,
        requested: quantity,
      );
    }
  }
}