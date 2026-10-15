import '../../data/datasources/sale_local_datasource.dart';
import '../../data/repositories/arrival_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../viewmodels/base_view_model.dart';

/// Période analysée dans les rapports.
enum ReportPeriod {
  /// Aujourd'hui.
  today,

  /// Les 7 derniers jours.
  week,

  /// Le mois en cours.
  month,

  /// Les 30 derniers jours.
  last30Days,
}

/// Libellé lisible d'une période.
extension ReportPeriodLabel on ReportPeriod {
  /// Texte affiché dans le sélecteur.
  String get label {
    switch (this) {
      case ReportPeriod.today:
        return 'Aujourd\'hui';
      case ReportPeriod.week:
        return 'Cette semaine';
      case ReportPeriod.month:
        return 'Ce mois';
      case ReportPeriod.last30Days:
        return '30 derniers jours';
    }
  }

  /// Bornes [début, fin] de la période.
  ({DateTime from, DateTime to}) get range {
    final DateTime now = DateTime.now();
    switch (this) {
      case ReportPeriod.today:
        return (
          from: DateTime(now.year, now.month, now.day),
          to: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case ReportPeriod.week:
        final DateTime start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        return (from: start, to: DateTime(now.year, now.month, now.day, 23, 59, 59));
      case ReportPeriod.month:
        return (
          from: DateTime(now.year, now.month),
          to: DateTime(now.year, now.month + 1, 1),
        );
      case ReportPeriod.last30Days:
        return (
          from: DateTime(now.year, now.month, now.day).subtract(
            const Duration(days: 29),
          ),
          to: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
    }
  }
}

/// ViewModel des rapports : indicateurs agrégés par SQLite.
class ReportsViewModel extends BaseViewModel {
  ReportsViewModel({
    required SaleRepository saleRepository,
    required ArrivalRepository arrivalRepository,
    required PaymentRepository paymentRepository,
  })  : _saleRepository = saleRepository,
        _arrivalRepository = arrivalRepository,
        _paymentRepository = paymentRepository;

  final SaleRepository _saleRepository;
  final ArrivalRepository _arrivalRepository;
  final PaymentRepository _paymentRepository;

  ReportPeriod _period = ReportPeriod.today;
  SaleSummary? _summary;
  int _purchases = 0;
  int _outstandingCredit = 0;

  /// Période sélectionnée.
  ReportPeriod get period => _period;

  /// Agrégats de ventes de la période.
  SaleSummary? get summary => _summary;

  /// Total des achats de la période.
  int get purchases => _purchases;

  /// Crédits encore ouverts (toutes périodes).
  int get outstandingCredit => _outstandingCredit;

  /// Change la période et recharge.
  Future<void> selectPeriod(ReportPeriod period) async {
    _period = period;
    await load();
  }

  /// Recharge les indicateurs de la période courante.
  Future<void> load() async {
    await guard(() async {
      setLoading();

      final ({DateTime from, DateTime to}) range = _period.range;
      _summary = await _saleRepository.getSummary(
        from: range.from,
        to: range.to,
      );
      _purchases = await _arrivalRepository.getTotalPurchase(
        from: range.from,
        to: range.to,
      );
      _outstandingCredit = await _paymentRepository
          .getTotalOutstandingCredit();

      setSuccess();
    });
  }
}