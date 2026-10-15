import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';

/// Card de contenu standard : fond de surface, coins arrondis, bordure discrète.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.cardPadding),
    this.onTap,
    this.color,
    this.borderColor,
  });

  /// Contenu de la card.
  final Widget child;

  /// Marge intérieure.
  final EdgeInsetsGeometry padding;

  /// Rend la card cliquable avec un ripple respectant les coins arrondis.
  final VoidCallback? onTap;

  /// Couleur de fond. Par défaut, la surface du thème actif.
  final Color? color;

  /// Couleur de bordure. Par défaut, la bordure du thème actif.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimensions.radius);
    final AppPalette palette = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? palette.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}