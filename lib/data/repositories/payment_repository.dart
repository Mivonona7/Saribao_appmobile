import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../database/app_database.dart';
import '../datasources/payment_local_datasource.dart';
import '../models/payment.dart';

/// Repository paiements : enregistre les versements des clients.
///
/// Un paiement diminue le crédit du client. S'il est imputé sur une vente
/// précise, le crédit et le statut de cette vente sont recalculés dans la
/// même transaction : aucune incohérence possible entre les deux.
class PaymentRepository {
  const PaymentRepository(this._appDatabase, this._dataSource);

  final AppDatabase _appDatabase;
  final PaymentLocalDataSource _dataSource;

  /// Vérifie la saisie d'un paiement.
  static void validate({required int amount, required int clientCredit}) {
    if (amount <= 0) {
      throw const ValidationException(
        'Le montant du paiement doit être supérieur à 0.',
      );
    }
    if (amount > clientCredit) {
      throw ValidationException(
        'Ce paiement de $amount Ar dépasse le crédit restant '
        'de $clientCredit Ar.',
      );
    }
  }

  /// Crédit restant d'un client.
  Future<int> getClientCredit(int clientId) =>
      _dataSource.getClientCredit(clientId);

  /// Total des crédits ouverts, tous clients confondus.
  Future<int> getTotalOutstandingCredit() =>
      _dataSource.getTotalOutstandingCredit();

  /// Clients endettés, du plus gros crédit au plus petit.
  Future<List<ClientCredit>> getClientsWithCredit() =>
      _dataSource.getClientsWithCredit();

  /// Enregistre un paiement.
  ///
  /// Si [saleId] est fourni, le paiement est imputé sur cette vente et le
  /// crédit de la vente est recalculé. Sinon il diminue le crédit global du
  /// client, calculé à la lecture par agrégation.
  Future<void> recordPayment({
    required int clientId,
    required int amount,
    int? saleId,
  }) async {
    final int credit = await _dataSource.getClientCredit(clientId);
    validate(amount: amount, clientCredit: credit);

    await _appDatabase.transaction<void>((Transaction txn) async {
      final Payment payment = Payment(
        clientId: clientId,
        saleId: saleId,
        amount: amount,
      );

      if (saleId == null) {
        await _dataSource.insert(payment, txn);
        return;
      }

      final int alreadyPaid = await _dataSource.getSalePaidAmount(txn, saleId);
      await _dataSource.insert(payment, txn);
      await _dataSource.applyToSale(txn, saleId, alreadyPaid + amount);
    });
  }

  /// Historique des paiements d'un client.
  Future<List<Payment>> getByClient(int clientId) =>
      _dataSource.getByClient(clientId);

  /// Paiements imputés sur une vente précise.
  Future<List<Payment>> getBySale(int saleId) => _dataSource.getBySale(saleId);

  /// Total versé par un client.
  Future<int> getClientTotalPaid(int clientId) =>
      _dataSource.getClientTotalPaid(clientId);
}