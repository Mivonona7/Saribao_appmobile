import '../database/database_tables.dart';

/// Mouvement de stock : trace d'un ajout ou d'un retrait de sacs.
///
/// Chaque mouvement porte le stock résultant ([stockAfter]) afin que
/// l'historique affiché soit toujours cohérent avec le stock actuel.
class StockMovement {
  const StockMovement({
    this.id,
    required this.movementType,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.label,
    required this.stockAfter,
    this.createdAt,
  });

  /// Identifiant local, `null` avant insertion.
  final int? id;

  /// Type de mouvement (ARRIVAL / SALE / CORRECTION).
  final String movementType;

  /// Quantité signée : positive en entrée, négative en sortie.
  final int quantity;

  /// Type de référence (`sale`, `arrival`, `manual`).
  final String? referenceType;

  /// Identifiant de la référence (vente ou arrivage).
  final int? referenceId;

  /// Libellé affiché dans l'historique.
  final String? label;

  /// Stock juste après ce mouvement.
  final int stockAfter;

  /// Date du mouvement.
  final DateTime? createdAt;

  /// `true` si le mouvement ajoute des sacs.
  bool get isPositive => quantity > 0;

  /// Libellé lisible du type de mouvement.
  String get typeLabel {
    switch (movementType) {
      case MovementType.arrival:
        return 'Arrivage';
      case MovementType.sale:
        return 'Vente';
      case MovementType.correction:
        return 'Correction';
      default:
        return movementType;
    }
  }

  @override
  String toString() =>
      'StockMovement(id: $id, type: $movementType, qty: $quantity)';
}