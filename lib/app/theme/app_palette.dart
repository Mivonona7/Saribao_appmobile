import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Couleurs qui changent selon le thème actif.
///
/// Les couleurs de marque (violet, succès, avertissement, erreur) restent
/// figées dans [AppColors] : elles doivent être identiques en clair et en
/// sombre pour que la charte reste reconnaissable. En revanche les surfaces,
/// le texte et les bordures ne peuvent pas : un fond blanc en mode sombre est
/// aveuglant.
///
/// Cette palette est jointe au [ThemeData] via [AppTheme], et lue avec
/// `context.appPalette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Construit une palette à partir de ses sept couleurs.
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.onSurface,
    required this.secondaryText,
    required this.border,
    required this.primarySoft,
    required this.onPrimary,
  });

  /// Palette utilisée par le thème clair.
  static const AppPalette light = AppPalette(
    background: AppColors.background,
    surface: AppColors.white,
    surfaceMuted: Color(0xFFF9FAFB),
    onSurface: AppColors.dark,
    secondaryText: AppColors.secondaryText,
    border: AppColors.border,
    primarySoft: AppColors.primaryLight,
    onPrimary: AppColors.white,
  );

  /// Palette utilisée par le thème sombre.
  ///
  /// Les fonds ne sont pas du noir pur : un gris bleuté tres sombre est plus
  /// confortable sur un ecran OLED et garde la separation des cartes visible.
  static const AppPalette dark = AppPalette(
    background: Color(0xFF121218),
    surface: Color(0xFF1E1E27),
    surfaceMuted: Color(0xFF26262F),
    onSurface: Color(0xFFF3F4F6),
    secondaryText: Color(0xFFA1A1AE),
    border: Color(0xFF33333F),
    primarySoft: Color(0xFF322C55),
    onPrimary: Color(0xFFFFFFFF),
  );

  /// Fond general des ecrans.
  final Color background;

  /// Fond des cartes, feuilles et surfaces surélevées.
  final Color surface;

  /// Fond des zones secondaires (en-tetes de section, pistes de liste).
  final Color surfaceMuted;

  /// Texte principal sur fond clair ou sombre.
  final Color onSurface;

  /// Texte secondaire, legendes et libelles moins importants.
  final Color secondaryText;

  /// Bordures de cartes, champs et séparateurs.
  final Color border;

  /// Variante douce du violet : fonds sélectionnés, pastilles.
  final Color primarySoft;

  /// Texte et icônes posés sur le violet.
  final Color onPrimary;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? onSurface,
    Color? secondaryText,
    Color? border,
    Color? primarySoft,
    Color? onPrimary,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      onSurface: onSurface ?? this.onSurface,
      secondaryText: secondaryText ?? this.secondaryText,
      border: border ?? this.border,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;

    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}

/// Accès court à la palette du thème courant.
extension AppPaletteContext on BuildContext {
  /// Palette du thème actif, avec repli sur la palette claire.
  ///
  /// Le repli evite une exception dans un `Widget` testé hors `MaterialApp` :
  /// les couleurs doivent toujours exister.
  AppPalette get appPalette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}