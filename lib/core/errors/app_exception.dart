/// Erreurs métier de SARIBAO.
///
/// Chaque erreur porte un message déjà rédigé en langage courant, directement
/// affichable à l'utilisateur : aucune exception ne doit exposer de détail
/// technique à l'écran.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Message affiché à l'utilisateur.
  final String message;

  @override
  String toString() => message;
}

/// Le stock disponible ne permet pas de couvrir la vente.
class InsufficientStockException extends AppException {
  InsufficientStockException({required this.available, required this.requested})
    : super(
        'Stock insuffisant : $requested sacs demandés, '
        'mais seulement $available sacs disponibles.',
      );

  /// Stock réellement disponible.
  final int available;

  /// Quantité demandée.
  final int requested;
}

/// Une donnée saisie est invalide.
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// L'opération demandée est impossible dans l'état actuel des données.
class BusinessRuleException extends AppException {
  const BusinessRuleException(super.message);
}

/// Le stock ne peut pas devenir négatif.
class StockUnderflowException extends AppException {
  StockUnderflowException({required this.available, required this.requested})
    : super(
        'Opération refusée : il reste $available sacs en stock, '
        'impossible d\'en retirer $requested.',
      );

  /// Stock réellement disponible.
  final int available;

  /// Quantité demandée.
  final int requested;
}