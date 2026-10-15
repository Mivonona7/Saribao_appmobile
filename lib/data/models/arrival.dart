/// Arrivage de charbon.
///
/// Le total n'est jamais saisi : il vaut toujours `quantity * purchasePrice`.
class Arrival {
  const Arrival({
    this.id,
    required this.quantity,
    required this.purchasePricePerBag,
    required this.totalPurchaseAmount,
    this.supplier,
    this.createdAt,
  });

  /// Identifiant local, `null` avant insertion.
  final int? id;

  /// Nombre de sacs reçus (>= 1).
  final int quantity;

  /// Prix d'achat d'un sac, en ariary.
  final int purchasePricePerBag;

  /// Total de l'achat : `quantity * purchasePricePerBag`.
  final int totalPurchaseAmount;

  /// Fournisseur (facultatif).
  final String? supplier;

  /// Date de l'arrivage.
  final DateTime? createdAt;

  /// Calcule le total d'achat.
  static int calculateTotal(int quantity, int purchasePricePerBag) =>
      quantity * purchasePricePerBag;

  @override
  String toString() => 'Arrival(id: $id, quantity: $quantity)';
}