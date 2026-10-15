import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';

/// Bouton principal, hauteur 52 px, texte en capitales.
///
/// [label] peut être vide si une icône seule est fournie sans ambiguïté.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color = AppColors.primary,
  });

  /// Texte du bouton.
  final String label;

  /// Action exécutée au tap. `null` désactive le bouton.
  final VoidCallback? onPressed;

  /// Icône optionnelle affichée avant le texte.
  final IconData? icon;

  /// Affiche un spinner et neutralise l'action pendant le traitement.
  final bool isLoading;

  /// Couleur de fond du bouton.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final AppPalette palette = context.appPalette;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: palette.border,
          disabledForegroundColor: palette.secondaryText,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconSize),
                    const SizedBox(width: AppDimensions.spacingSm),
                  ],
                  Flexible(
                    child: Text(
                      label.toUpperCase(),
                      style: AppTextStyles.button.copyWith(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Bouton secondaire, contour seul, même hauteur que [AppButton].
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.primary,
  });

  /// Texte du bouton.
  final String label;

  /// Action exécutée au tap. `null` désactive le bouton.
  final VoidCallback? onPressed;

  /// Icône optionnelle affichée avant le texte.
  final IconData? icon;

  /// Couleur du contour et du texte.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: palette.secondaryText,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppDimensions.iconSize),
              const SizedBox(width: AppDimensions.spacingSm),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.button.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}