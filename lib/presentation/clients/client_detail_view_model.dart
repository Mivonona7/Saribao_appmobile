import '../../data/models/client.dart';
import '../../data/models/payment.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../viewmodels/base_view_model.dart';

/// Profil d'un client : identity, totaux, ventes et paiements.
class ClientDetailViewModel extends BaseViewModel {
  ClientDetailViewModel({
    required ClientRepository clientRepository,
    required SaleRepository saleRepository,
    required PaymentRepository paymentRepository,
    required int clientId,
  })  : _clientRepository = clientRepository,
        _saleRepository = saleRepository,
        _paymentRepository = paymentRepository,
        _clientId = clientId;
  final ClientRepository _clientRepository;
  final SaleRepository _saleRepository;
  final PaymentRepository _paymentRepository;
  final int _clientId;

  Client? _client;
  List<Sale> _sales = <Sale>[];
  List<Payment> _payments = <Payment>[];
  int _credit = 0;
  int _totalPurchases = 0;
  int _totalPaid = 0;
  bool _isSavingPayment = false;

  /// Client chargé.
  Client? get client => _client;

  /// Ventes du client, de la plus récente à la plus ancienne.
  List<Sale> get sales => _sales;

  /// Paiements du client, du plus récent au plus ancien.
  List<Payment> get payments => _payments;

  /// Crédit restant du client.
  int get credit => _credit;

  /// Total des achats du client.
  int get totalPurchases => _totalPurchases;

  /// Total déjà réglé par le client.
  int get totalPaid => _totalPaid;

  /// `true` pendant l'enregistrement d'un paiement.
  bool get isSavingPayment => _isSavingPayment;

  /// Identifiant du client affiché.
  int get clientId => _clientId;

  /// Recharge le profil complet.
  Future<void> load() async {
    await guard(() async {
      setLoading();

      _client = await _clientRepository.getById(_clientId);
      if (_client == null) {
        setError('Ce client est introuvable.');
        return;
      }

      _sales = await _saleRepository.getByClient(_clientId);
      _payments = await _paymentRepository.getByClient(_clientId);
      _credit = await _paymentRepository.getClientCredit(_clientId);
      _totalPaid = await _paymentRepository.getClientTotalPaid(_clientId);
      _totalPurchases = _sales.fold<int>(
        0,
        (int sum, Sale sale) => sum + sale.totalAmount,
      );

      setSuccess();
    });
  }

  /// Enregistre un paiement. Renvoie le message d'erreur, ou `null` si succès.
  Future<String?> recordPayment(int amount, {int? saleId}) async {
    _isSavingPayment = true;
    safeNotify();

    try {
      await _paymentRepository.recordPayment(
        clientId: _clientId,
        amount: amount,
        saleId: saleId,
      );
      await load();
      return null;
    } catch (error) {
      return describeError(error);
    } finally {
      _isSavingPayment = false;
      safeNotify();
    }
  }
}