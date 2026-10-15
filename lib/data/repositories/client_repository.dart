import '../../core/errors/app_exception.dart';
import '../datasources/client_local_datasource.dart';
import '../models/client.dart';

/// Repository clients : validation puis accès SQLite.
///
/// Les règles de validation vivent ici (et dans le ViewModel pour le retour
/// immédiat), jamais dans les vues.
class ClientRepository {
  const ClientRepository(this._dataSource);

  final ClientLocalDataSource _dataSource;

  /// Vérifie qu'un nom de client est acceptable.
  static void validateName(String name) {
    if (name.trim().isEmpty) {
      throw const ValidationException('Le nom du client est obligatoire.');
    }
  }

  /// Tous les clients.
  Future<List<Client>> getAll() => _dataSource.getAll();

  /// Client par identifiant.
  Future<Client?> getById(int id) => _dataSource.getById(id);

  /// Recherche par nom ou téléphone.
  Future<List<Client>> search(String query) => _dataSource.search(query);

  /// Crée un client et renvoie son identifiant.
  Future<int> create(Client client) async {
    validateName(client.name);
    return _dataSource.insert(
      client.copyWith(name: client.name.trim()),
    );
  }

  /// Met à jour un client.
  Future<void> update(Client client) async {
    validateName(client.name);
    if (client.id == null) {
      throw const ValidationException(
        'Impossible de modifier un client non enregistré.',
      );
    }
    await _dataSource.update(
      client.copyWith(name: client.name.trim()),
    );
  }

  /// Supprime un client s'il ne possède aucune vente.
  Future<void> delete(int id) async {
    final Client? client = await _dataSource.getById(id);
    if (client == null) {
      throw const BusinessRuleException('Ce client n\'existe plus.');
    }
    // Les clés étrangères protègent déjà la base ; ce message améliore
    // simplement ce que comprend l'utilisateur.
    try {
      await _dataSource.delete(id);
    } catch (error) {
      throw const BusinessRuleException(
        'Ce client a déjà des ventes ou des paiements : '
        'il ne peut pas être supprimé.',
      );
    }
  }
}