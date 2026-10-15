import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

/// Logo SARIBAO chargé depuis `assets/logos/`.
///
/// Le fichier est embarqué dans l'application : aucun accès réseau, aucun
/// risque d'icône manquante au premier lancement.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.showBackground = true,
  });

  /// Taille du carré contenant le logo.
  final double size;

  /// Ajoute le disque de couleur principale derrière le logo.
  ///
  /// À désactiver si l'image possède déjà son propre fond.
  final bool showBackground;

  /// Chemin de l'asset, isolé ici pour changer de logo sans toucher aux vues.
  static const String assetPath = 'assets/logos/charbon.png';

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Ne pas confondre un logo absent avec une image vide : on affiche
      // toujours la zone réservée.
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return Icon(
          Icons.local_fire_department_rounded,
          size: size * 0.7,
          color: Theme.of(context).colorScheme.onPrimary,
        );
      },
    );

    if (!showBackground) return image;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: image,
    );
  }

  /// Taille par défaut d'un logo dans une barre d'application.
  static const double appBarSize = AppDimensions.iconSize;
}