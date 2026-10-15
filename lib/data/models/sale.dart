import '../../core/constants/app_constants.dart';
import '../database/database_tables.dart';

/// Vente de sacs de charbon.
///
/// `totalAmount`, `creditAmount` et `paymentStatus` ne sont jamais saisis par
/// l'utilisateur : ils sont calculés par le use case à partir de la quantité,
/// du prix unitaire et du montant payé.
class Sale {
  const Sale({
    this.id,
    this.clientId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.paidAmount,
    required this.creditAmount,
    required this.paymentStatus,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  /// Identifiant local, `null` avant insertion.
  final int? id;

  /// Client acheteur, `null` pour une vente comptoir.
  final int? clientId;

  /// Nombre de sacs vendus (>= 1).
  final int quantity;

  /// Prix de vente d'un sac, en ariary (> 0).
  final int unitPrice;

  /// Total de la vente : `quantity * unitPrice`.
  final int totalAmount;

  /// Montant déjà réglé.
  final int paidAmount;

  /// Reste dû : `totalAmount - paidAmount`.
  final int creditAmount;

  /// Statut de paiement (PAYED / PARTIAL / CREDIT).
  final String paymentStatus;

  /// Note libre facultative.
  final String? note;

  /// Date de création.
  final DateTime? createdAt;

  /// Date de dernière modification.
  final DateTime? updatedAt;

  /// `true` si la vente est entièrement réglée.
  bool get isFullyPaid => creditAmount == 0;

  /// Calcule le total à partir de la quantité et du prix unitaire.
  static int calculateTotal(int quantity, int unitPrice) =>
      quantity * unitPrice;

  /// Calcule le crédit restant.
  static int calculateCredit(int totalAmount, int paidAmount) =>
      totalAmount - paidAmount;

  /// Détermine le statut de paiement à partir des montants.
  static String resolveStatus(int totalAmount, int paidAmount) {
    if (paidAmount <= 0) return PaymentStatus.credit;
    if (paidAmount >= totalAmount) return PaymentStatus.paid;
    return PaymentStatus.partial;
  }

  /// Unité du produit, rappelée ici pour l'affichage.
  String get unitLabel => AppConstants.unitLabel;

  /// Copie avec les champs fournis modifiés.
  Sale copyWith({
    int? id,
    int? clientId,
    int? quantity,
    int? unitPrice,
    int? totalAmount,
    int? paidAmount,
    int? creditAmount,
    String? paymentStatus,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Sale(id: $id, quantity: $quantity, total: $totalAmount)';
}