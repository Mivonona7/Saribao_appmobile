import '../../data/datasources/payment_local_datasource.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../viewmodels/base_view_model.dart';

/// ViewModel de la liste des clients : recherche et crédits associés.
class ClientsViewModel extends BaseViewModel {
  ClientsViewModel({
    required ClientRepository clientRepository,
    required PaymentRepository paymentRepository,
  })  : _clientRepository = clientRepository,
        _paymentRepository = paymentRepository;

  final ClientRepository _clientRepository;
  final PaymentRepository _paymentRepository;

  List<Client> _clients = <Client>[];
  Map<int, int> _credits = <int, int>{};
  String _query = '';

  /// Clients affichés.
  List<Client> get clients => _clients;

  /// Dernière recherche saisie.
  String get query => _query;

  /// Crédit restant par client (0 si soldé).
  int creditOf(int clientId) => _credits[clientId] ?? 0;

  /// Recharge la liste complète.
  Future<void> load() async {
    await guard(() async {
      setLoading();
      await _reload();
      setSuccess();
    });
  }

  /// Filtre la liste par nom ou téléphone.
  Future<void> search(String query) async {
    _query = query;
    await guard(() async {
      await _reload();
      setSuccess();
    });
  }

  /// Supprime un client après confirmation.
  Future<void> delete(Client client) async {
    if (client.id == null) return;
    try {
      await _clientRepository.delete(client.id!);
      await _reload();
    } catch (error) {
      setError(describeError(error));
    }
  }

  Future<void> _reload() async {
    final List<Client> clients = _query.trim().isEmpty
        ? await _clientRepository.getAll()
        : await _clientRepository.search(_query);

    _clients = clients;

    // Crédits chargés en une requête, pas un par client.
    final List<ClientCredit> debts =
        await _paymentRepository.getClientsWithCredit();
    _credits = <int, int>{
      for (final ClientCredit debt in debts) debt.clientId: debt.credit,
    };

    if (_clients.isEmpty) setEmpty();
  }
}