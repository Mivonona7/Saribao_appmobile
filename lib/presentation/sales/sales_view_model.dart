import '../../data/models/client.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../viewmodels/base_view_model.dart';

/// ViewModel de l'historique des ventes.
class SalesViewModel extends BaseViewModel {
  SalesViewModel({
    required SaleRepository saleRepository,
    required ClientRepository clientRepository,
  })  : _saleRepository = saleRepository,
        _clientRepository = clientRepository;

  final SaleRepository _saleRepository;
  final ClientRepository _clientRepository;

  static const int pageSize = 50;

  List<Sale> _sales = <Sale>[];
  final Map<int, String> _clientNames = <int, String>{};
  bool _isLoadingMore = false;
  bool _hasMore = true;

  /// Ventes chargées.
  List<Sale> get sales => _sales;

  /// `true` si une page est en cours de chargement.
  bool get isLoadingMore => _isLoadingMore;

  /// `true` si des ventes restent à charger.
  bool get hasMore => _hasMore;

  /// Nom du client d'une vente, ou `null` pour une vente comptoir.
  String? clientNameOf(Sale sale) => _clientNames[sale.clientId];

  /// Recharge la première page.
  Future<void> load() async {
    await guard(() async {
      setLoading();
      _sales = await _saleRepository.getAll(limit: pageSize);
      _hasMore = _sales.length >= pageSize;
      await _loadClientNames();
      setSuccess();
    });
  }

  /// Charge la page suivante.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    safeNotify();

    try {
      final List<Sale> next = await _saleRepository.getAll(
        limit: pageSize,
        offset: _sales.length,
      );
      _sales = <Sale>[..._sales, ...next];
      _hasMore = next.length >= pageSize;
      await _loadClientNames();
    } catch (error) {
      setError(describeError(error));
    } finally {
      _isLoadingMore = false;
      safeNotify();
    }
  }

  /// Noms des clients présents sur les ventes chargées.
  ///
  /// Résolus uniquement pour les identifiants affichés : charger toute la
  /// table clients serait inutile et coûteux avec des milliers de ventes.
  Future<void> _loadClientNames() async {
    final Set<int> missing = <int>{
      for (final Sale sale in _sales)
        if (sale.clientId != null && !_clientNames.containsKey(sale.clientId))
          sale.clientId!,
    };

    for (final int clientId in missing) {
      final Client? client = await _clientRepository.getById(clientId);
      if (client != null) _clientNames[clientId] = client.name;
    }
  }
}