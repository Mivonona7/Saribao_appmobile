import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Hiérarchie typographique de SARIBAO.
///
/// `Inter` est demandée comme famille. Les fichiers `.ttf` ne sont pas encore
/// embarqués dans le projet : Flutter bascule alors silencieusement sur la police
/// système, sans erreur de build. Pour activer la vraie Inter plus tard :
/// déposer les `.ttf` dans `assets/fonts/`, les déclarer dans `pubspec.yaml`
/// (section `flutter: fonts:`). Aucun autre fichier n'a besoin d'être modifié.
abstract final class AppTextStyles {
  /// Nom de la famille de texte demandée pour l'application.
  static const String fontFamily = 'Inter';

  /// Titre de niveau 1 — 24 px, gras.
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
    height: 1.25,
  );

  /// Titre de niveau 2 — 20 px, gras.
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
    height: 1.3,
  );

  /// Titre de niveau 3 — 18 px, semi-gras.
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
    height: 1.3,
  );

  /// Texte courant — 16 px.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.dark,
    height: 1.4,
  );

  /// Texte secondaire — 14 px.
  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  /// Légende et label discret — 12 px.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.35,
  );

  /// Variante de `caption` en gras, pour les libellés de statut.
  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.secondaryText,
    height: 1.35,
  );

  /// Valeur chiffrée mise en avant (montants, quantités).
  static const TextStyle amount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
    height: 1.2,
  );

  /// Grand chiffre (stock disponible sur le dashboard).
  static const TextStyle displayNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1.1,
  );

  /// Libellé de bouton en capitales, lisible et generous.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.2,
  );

  /// Variante de `body` en gras, pour les prix et totaux.
  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
    height: 1.4,
  );
}