import '../../data/models/arrival.dart';
import '../../data/repositories/arrival_repository.dart';
import '../viewmodels/base_view_model.dart';

/// ViewModel de l'écran Arrivages : historique paginé.
class ArrivalsViewModel extends BaseViewModel {
  ArrivalsViewModel({required ArrivalRepository arrivalRepository})
    : _arrivalRepository = arrivalRepository;

  final ArrivalRepository _arrivalRepository;

  static const int pageSize = 50;

  List<Arrival> _arrivals = <Arrival>[];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  /// Arrivages chargés.
  List<Arrival> get arrivals => _arrivals;

  /// `true` si une page est en cours de chargement.
  bool get isLoadingMore => _isLoadingMore;

  /// `true` si des arrivages restent à charger.
  bool get hasMore => _hasMore;

  /// Recharge la première page.
  Future<void> load() async {
    await guard(() async {
      setLoading();
      _arrivals = await _arrivalRepository.getAll(limit: pageSize);
      _hasMore = _arrivals.length >= pageSize;
      setSuccess();
    });
  }

  /// Charge la page suivante.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    safeNotify();

    try {
      final List<Arrival> next = await _arrivalRepository.getAll(
        limit: pageSize,
        offset: _arrivals.length,
      );
      _arrivals = <Arrival>[..._arrivals, ...next];
      _hasMore = next.length >= pageSize;
    } catch (error) {
      setError(describeError(error));
    } finally {
      _isLoadingMore = false;
      safeNotify();
    }
  }
}