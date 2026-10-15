/// Dimensions et espacements centralisés.
///
/// Aucun magic number dans les vues : utiliser `AppDimensions.*`.
abstract final class AppDimensions {
  // Écrans
  /// Padding horizontal/vertical standard des écrans (16 px).
  static const double screenPadding = 16;

  /// Marge intérieure des cards (16 px).
  static const double cardPadding = 16;

  // Rayons
  /// Rayon principal des cards et dialogues (16 px).
  static const double radius = 16;

  /// Rayon des champs de saisie et petits éléments (12 px).
  static const double radiusSmall = 12;

  /// Rayon des composants très compacts, pastilles (8 px).
  static const double radiusTiny = 8;

  // Boutons
  /// Hauteur des boutons principaux (52 px).
  static const double buttonHeight = 52;

  /// Hauteur des boutons secondaires et boutons d'icône (48 px).
  static const double buttonHeightSmall = 48;

  /// Taille minimale d'une zone tactile (48 px).
  static const double minTouchTarget = 48;

  // Espacements
  /// 4 px.
  static const double spacingXs = 4;

  /// 8 px.
  static const double spacingSm = 8;

  /// 12 px.
  static const double spacingMd = 12;

  /// 16 px.
  static const double spacingLg = 16;

  /// 24 px.
  static const double spacingXl = 24;

  /// 32 px.
  static const double spacingXxl = 32;

  // Listes
  /// Hauteur maximale d'une barre d'onglets pour rester comfortably tactile.
  static const double bottomNavHeight = 64;

  /// Taille d'une icône de navigation standard.
  static const double iconSize = 24;

  /// Taille d'une icône de navigation sélectionnée.
  static const double iconSizeActive = 26;
}