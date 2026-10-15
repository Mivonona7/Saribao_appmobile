import 'package:flutter/material.dart';

/// Palette unique de SARIBAO.
///
/// Ce fichier est le seul endroit du projet où des valeurs hexadécimales
/// de couleur sont autorisées. Partout ailleurs, utiliser `AppColors.x`.
abstract final class AppColors {
  /// Couleur principale de l'application.
  static const Color primary = Color(0xFF6C5CE7);

  /// Variante claire utilisée pour les fonds selected (ex. onglets actifs).
  static const Color primaryLight = Color(0xFFEDE9FE);

  /// Blanc pur, utilisé pour les surfaces et le texte sur fond coloré.
  static const Color white = Color(0xFFFFFFFF);

  /// Texte principal sur fond clair.
  static const Color dark = Color(0xFF1F2937);

  /// Fond général de l'application.
  static const Color background = Color(0xFFF5F6FA);

  /// Texte secondaire, légendes et libellés moins importants.
  static const Color secondaryText = Color(0xFF6B7280);

  /// Bordures de cartes, champs et séparateurs.
  static const Color border = Color(0xFFE5E7EB);

  /// Succès : opération réussie, vente payée, stock normal.
  static const Color success = Color(0xFF22C55E);

  /// Avertissement : crédits, stocks bas.
  static const Color warning = Color(0xFFF59E0B);

  /// Erreur : action refusée, champ invalide.
  static const Color error = Color(0xFFEF4444);
}