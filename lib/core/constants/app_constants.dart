/// Constantes métier et d'affichage de l'application.
abstract final class AppConstants {
  /// Nom affiché de l'application.
  static const String appName = 'SARIBAO';

  /// Sous-titre affiché sur le splash.
  static const String appTagline = 'Gestion de vente de charbon';

  /// Suffixe des montants en ariary (Madagascar).
  static const String currencySuffix = 'Ar';

  /// Unité de vente : le sac.
  static const String unitLabel = 'sac';

  /// Plural de [unitLabel].
  static const String pluralUnitLabel = 'sacs';

  /// Quantité minimale d'une vente ou d'un arrivage.
  static const int minQuantity = 1;

  /// Seuils d'affichage de l'indicateur de stock.
  static const int lowStockThreshold = 20;
  static const int mediumStockThreshold = 50;
}