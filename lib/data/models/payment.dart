/// Paiement reçu d'un client, diminuant son crédit.
///
/// Si [saleId] est renseigné, le paiement est imputé sur une vente précise,
/// sinon il est imputé sur l'ensemble du crédit du client.
class Payment {
  const Payment({
    this.id,
    required this.clientId,
    this.saleId,
    required this.amount,
    this.createdAt,
  });

  /// Identifiant local, `null` avant insertion.
  final int? id;

  /// Client ayant réglé.
  final int clientId;

  /// Vente imputée, `null` si le paiement porte sur tout le crédit.
  final int? saleId;

  /// Montant versé, en ariary (> 0).
  final int amount;

  /// Date du paiement.
  final DateTime? createdAt;

  @override
  String toString() => 'Payment(id: $id, clientId: $clientId, amount: $amount)';
}