import '../../data/database/app_database.dart';
import '../../data/datasources/arrival_local_datasource.dart';
import '../../data/datasources/client_local_datasource.dart';
import '../../data/datasources/payment_local_datasource.dart';
import '../../data/datasources/sale_local_datasource.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/datasources/stock_local_datasource.dart';
import '../../data/repositories/arrival_repository.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/stock_repository.dart';

/// Injection de dépendances légère.
///
/// Construit une seule fois les data sources et les repositories, puis les
/// expose à l'application via `provider`. Aucun conteneur externe : juste une
/// fabrique explicite, ce qui reste le plus simple à maintenir.
class AppDependencies {
AppDependencies._({
    required this.clientRepository,
    required this.saleRepository,
    required this.arrivalRepository,
    required this.paymentRepository,
    required this.stockRepository,
    required this.settingsRepository,
  });

  /// Construit l'ensemble des repositories à partir de la base de données.
  factory AppDependencies.create() {
    final AppDatabase db = AppDatabase.instance;

    final ClientLocalDataSource clientDataSource =
        ClientLocalDataSource(db);
    final SaleLocalDataSource saleDataSource = SaleLocalDataSource(db);
    final ArrivalLocalDataSource arrivalDataSource =
        ArrivalLocalDataSource(db);
    final PaymentLocalDataSource paymentDataSource =
        PaymentLocalDataSource(db);
    final StockLocalDataSource stockDataSource = StockLocalDataSource(db);
    final SettingsLocalDataSource settingsDataSource =
        SettingsLocalDataSource(db);

    return AppDependencies._(
      clientRepository: ClientRepository(clientDataSource),
      saleRepository: SaleRepository(
        db,
        saleDataSource,
        stockDataSource,
        paymentDataSource,
      ),
      arrivalRepository: ArrivalRepository(
        db,
        arrivalDataSource,
        stockDataSource,
      ),
      paymentRepository: PaymentRepository(db, paymentDataSource),
      stockRepository: StockRepository(stockDataSource),
      settingsRepository: SettingsRepository(settingsDataSource),
    );
  }

  /// Repository clients.
  final ClientRepository clientRepository;

  /// Repository ventes.
  final SaleRepository saleRepository;

  /// Repository arrivages.
  final ArrivalRepository arrivalRepository;

  /// Repository paiements et crédits.
  final PaymentRepository paymentRepository;

  /// Repository stock.
  final StockRepository stockRepository;

  /// Repository des préférences utilisateur (apparence, langue).
  final SettingsRepository settingsRepository;
}