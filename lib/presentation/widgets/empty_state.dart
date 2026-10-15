import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';

/// Affichage « aucune donnée » : icône, message explicite et action optionnelle.
///
/// L'information n'est jamais portée par la couleur seule : icône + texte.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  /// Titre court de l'état vide.
  final String title;

  /// Message explicatif, en langage courant.
  final String message;

  /// Icône d'illustration.
  final IconData icon;

  /// Libellé du bouton d'action, si une action est possible.
  final String? actionLabel;

  /// Action exécutée au tap.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.appPalette.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              style: AppTextStyles.small,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    180,
                    AppDimensions.buttonHeight,
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  textStyle: AppTextStyles.button,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}