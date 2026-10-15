import '../../data/models/stock_movement.dart';
import '../../data/repositories/stock_repository.dart';
import '../viewmodels/base_view_model.dart';

/// ViewModel de l'écran Stock : quantité actuelle et historique paginé.
class StockViewModel extends BaseViewModel {
  StockViewModel({required StockRepository stockRepository})
    : _stockRepository = stockRepository;

  final StockRepository _stockRepository;

  /// Nombre de mouvements chargés par page.
  static const int pageSize = 50;

  int _stockQuantity = 0;
  List<StockMovement> _movements = <StockMovement>[];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  /// Stock actuel en sacs.
  int get stockQuantity => _stockQuantity;

  /// Mouvements déjà chargés.
  List<StockMovement> get movements => _movements;

  /// `true` si une page est en cours de chargement.
  bool get isLoadingMore => _isLoadingMore;

  /// `true` si des mouvements restent à charger.
  bool get hasMore => _hasMore;

  /// Recharge le stock et la première page d'historique.
  Future<void> load() async {
    await guard(() async {
      setLoading();
      await _reload();
      setSuccess();
    });
  }

  /// Charge la page suivante d'historique.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    safeNotify();

    try {
      await _reload();
    } catch (error) {
      setError(describeError(error));
    } finally {
      _isLoadingMore = false;
      safeNotify();
    }
  }

  Future<void> _reload() async {
    _stockQuantity = await _stockRepository.getCurrentStock();
    _movements = await _stockRepository.getMovements(limit: pageSize);
    _hasMore = _movements.length >= pageSize;
  }
}