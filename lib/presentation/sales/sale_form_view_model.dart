import '../../data/models/client.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../viewmodels/base_view_model.dart';

/// Mode de paiement choisi dans le formulaire de vente.
enum SalePaymentMode {
  /// Vente intégralement payée.
  paid,

  /// Vente à crédit : le client règle plus tard.
  credit,

  /// Vente partielle : une partie est réglée maintenant.
  partial,
}

/// ViewModel du formulaire de vente.
///
/// Calcule le total et le crédit à partir de la quantité et du prix : le
/// total n'est jamais demandé à l'utilisateur.
class SaleFormViewModel extends BaseViewModel {
  SaleFormViewModel({
    required this._saleRepository,
    required this._clientRepository,
  });

  final SaleRepository _saleRepository;
  final ClientRepository _clientRepository;

  int _quantity = 1;
  int _unitPrice = 0;
  int _paidAmount = 0;
  SalePaymentMode _mode = SalePaymentMode.paid;
  Client? _selectedClient;
  String? _quantityError;
  String? _priceError;
  String? _clientError;
  bool _isSaving = false;
  int _availableStock = 0;

  List<Client> _searchResults = <Client>[];
  bool _isSearching = false;

  /// Nombre de sacs actuellement sélectionné.
  int get quantity => _quantity;

  /// Prix unitaire saisi.
  int get unitPrice => _unitPrice;

  /// Montant payé saisi.
  int get paidAmount => _paidAmount;

  /// Mode de paiement choisi.
  SalePaymentMode get mode => _mode;

  /// Client sélectionné, `null` pour une vente comptoir.
  Client? get selectedClient => _selectedClient;

  /// Total calculé : `quantity * unitPrice`.
  int get total => SaleRepository.computeTotal(_quantity, _unitPrice);

  /// Crédit calculé : `total - paidAmount`.
  int get credit => total - _paidAmount;

  /// Stock disponible avant la vente.
  int get availableStock => _availableStock;

  /// Erreur du champ quantité.
  String? get quantityError => _quantityError;

  /// Erreur du champ prix.
  String? get priceError => _priceError;

  /// Erreur de sélection du client.
  String? get clientError => _clientError;

  /// `true` pendant l'enregistrement.
  bool get isSaving => _isSaving;

  /// Résultats de recherche de clients.
  List<Client> get searchResults => _searchResults;

  /// `true` pendant une recherche.
  bool get isSearching => _isSearching;

  /// `true` si le stock ne suffit pas pour la quantité demandée.
  bool get exceedsStock => _quantity > _availableStock;

  /// Charge le stock disponible.
  Future<void> loadStock() async {
    await guard(() async {
      _availableStock = await _saleRepository.getAvailableStock();
      safeNotify();
    });
  }

  /// Change la quantité (bornée à 1 minimum).
  void setQuantity(int value) {
    _quantity = value < 1 ? 1 : value;
    _quantityError = null;
    safeNotify();
  }

  /// Change le prix unitaire.
  void setUnitPrice(int value) {
    _unitPrice = value < 0 ? 0 : value;
    _priceError = null;
    _syncPaidAmount();
    safeNotify();
  }

  /// Change le montant payé.
  void setPaidAmount(int value) {
    _paidAmount = value < 0 ? 0 : value;
    _syncPaidAmount();
    safeNotify();
  }

  /// Change le mode de paiement.
  void setMode(SalePaymentMode mode) {
    _mode = mode;
    // Le montant payé est aligné sur le mode : total si payé, 0 si crédit.
    switch (mode) {
      case SalePaymentMode.paid:
        _paidAmount = total;
      case SalePaymentMode.credit:
        _paidAmount = 0;
      case SalePaymentMode.partial:
        break;
    }
    safeNotify();
  }

  /// Aligne le montant payé pour qu'il ne dépasse jamais le total.
  void _syncPaidAmount() {
    if (_mode == SalePaymentMode.paid) {
      _paidAmount = total;
      return;
    }
    if (_paidAmount > total) _paidAmount = total;
  }

  /// Sélectionne un client.
  void selectClient(Client? client) {
    _selectedClient = client;
    _clientError = null;
    safeNotify();
  }

  /// Recherche des clients pour le sélecteur.
  Future<void> searchClients(String query) async {
    await guard(() async {
      _isSearching = true;
      safeNotify();
      try {
        _searchResults = await _clientRepository.search(query);
      } finally {
        _isSearching = false;
        safeNotify();
      }
    });
  }

  /// Valide le formulaire courant.
  bool validate() {
    _quantityError = _quantity < 1 ? 'Au moins 1 sac.' : null;
    _priceError = _unitPrice <= 0 ? 'Le prix doit être supérieur à 0.' : null;
    _clientError = (_mode != SalePaymentMode.credit && _selectedClient == null)
        ? 'Choisissez le client qui achète.'
        : null;

    safeNotify();
    return _quantityError == null &&
        _priceError == null &&
        _clientError == null;
  }

  /// Enregistre la vente. Renvoie un message d'erreur, ou `null` si succès.
  Future<String?> submit({String? note}) async {
    if (!validate()) return 'Vérifiez les champs en rouge.';

    _isSaving = true;
    safeNotify();

    try {
      await _saleRepository.createSale(
        clientId: _selectedClient?.id,
        quantity: _quantity,
        unitPrice: _unitPrice,
        paidAmount: _paidAmount,
        note: note,
      );
      _availableStock = await _saleRepository.getAvailableStock();
      return null;
    } catch (error) {
      return describeError(error);
    } finally {
      _isSaving = false;
      safeNotify();
    }
  }

  /// Ventes du client sélectionné, pour information.
  Future<List<Sale>> getClientSales() async {
    final int? clientId = _selectedClient?.id;
    if (clientId == null) return <Sale>[];
    return _saleRepository.getByClient(clientId, limit: 5);
  }
}