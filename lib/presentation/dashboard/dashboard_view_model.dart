import 'package:flutter/foundation.dart';

import '../../data/models/sale.dart';
import '../../data/datasources/sale_local_datasource.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../viewmodels/base_view_model.dart';

/// Vente récente affichée sur le dashboard, avec son nom de client.
@immutable
class RecentSaleItem {
  const RecentSaleItem({
    required this.sale,
    required this.clientName,
  });

  /// Vente concernée.
  final Sale sale;

  /// Nom du client, ou libellé générique pour une vente comptoir.
  final String clientName;
}

/// ViewModel du dashboard : indicateurs du jour et dernières ventes.
///
/// Ne contient aucune logique de présentation ni de SQL : toute la lecture
/// passe par les repositories.
class DashboardViewModel extends BaseViewModel {
  DashboardViewModel({
    required StockRepository stockRepository,
    required SaleRepository saleRepository,
    required PaymentRepository paymentRepository,
    required ClientRepository clientRepository,
  })  : _stockRepository = stockRepository,
        _saleRepository = saleRepository,
        _paymentRepository = paymentRepository,
        _clientRepository = clientRepository;

  final StockRepository _stockRepository;
  final SaleRepository _saleRepository;
  final PaymentRepository _paymentRepository;
  final ClientRepository _clientRepository;

  int _stockQuantity = 0;
  int _todaySalesQuantity = 0;
  int _todayRevenue = 0;
  int _outstandingCredits = 0;
  List<RecentSaleItem> _recentSales = <RecentSaleItem>[];

  /// Stock actuel en sacs.
  int get stockQuantity => _stockQuantity;

  /// Sacs vendus aujourd'hui.
  int get todaySalesQuantity => _todaySalesQuantity;

  /// Chiffre d'affaires du jour, en ariary.
  int get todayRevenue => _todayRevenue;

  /// Total des crédits restant à récupérer.
  int get outstandingCredits => _outstandingCredits;

  /// Dernières ventes, de la plus récente à la plus ancienne.
  List<RecentSaleItem> get recentSales => _recentSales;

  /// `true` si l'activité est totalement vide (aucune vente).
  bool get hasSales => _recentSales.isNotEmpty;

  /// Bornes de la journée en cours.
  static ({DateTime from, DateTime to}) get _todayRange {
    final DateTime now = DateTime.now();
    return (
      from: DateTime(now.year, now.month, now.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  /// Recharge toutes les données du dashboard.
  Future<void> load() async {
    await guard(() async {
      setLoading();

      final ({DateTime from, DateTime to}) range = _todayRange;
      final SaleSummary summary = await _saleRepository.getSummary(
        from: range.from,
        to: range.to,
      );

      _stockQuantity = await _stockRepository.getCurrentStock();
      _todaySalesQuantity = summary.bagsSold;
      _todayRevenue = summary.revenue;
      _outstandingCredits = await _paymentRepository
          .getTotalOutstandingCredit();
      _recentSales = await _loadRecentSales();

      setSuccess();
    });
  }

  Future<List<RecentSaleItem>> _loadRecentSales() async {
    final List<Sale> sales = await _saleRepository.getRecent(limit: 5);

    // Résolution des noms : chargé uniquement pour les clients concernés,
    // pas toute la table.
    final Map<int, String> names = <int, String>{};
    for (final Sale sale in sales) {
      final int? clientId = sale.clientId;
      if (clientId == null) continue;
      if (names.containsKey(clientId)) continue;
      final client = await _clientRepository.getById(clientId);
      if (client != null) names[clientId] = client.name;
    }

    return sales
        .map(
          (Sale sale) => RecentSaleItem(
            sale: sale,
            clientName: names[sale.clientId] ?? 'Client comptoir',
          ),
        )
        .toList(growable: false);
  }
}