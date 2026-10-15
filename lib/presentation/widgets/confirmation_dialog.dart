import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';

/// Dialog de confirmation pour les actions importantes.
///
/// Retourne `true` si l'utilisateur confirme, `false` s'il annule.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmer',
  String cancelLabel = 'Annuler',
  bool isDestructive = false,
  List<Widget> details = const <Widget>[],
}) async {
  final AppPalette palette = context.appPalette;

  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      title: Text(title, style: Theme.of(dialogContext).textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(dialogContext).textTheme.bodyMedium),
          if (details.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            for (final Widget detail in details) detail,
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        0,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.secondaryText,
                    side: BorderSide(color: palette.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius,
                      ),
                    ),
                  ),
                  child: Text(cancelLabel.toUpperCase()),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: SizedBox(
                height: AppDimensions.buttonHeight,
                child: FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDestructive
                        ? AppColors.error
                        : AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                  ),
                  child: Text(confirmLabel.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return result ?? false;
}

/// Ligne « libellé : valeur » utilisée dans un dialogue de confirmation.
class ConfirmationDetailRow extends StatelessWidget {
  const ConfirmationDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  /// Libellé du champ.
  final String label;

  /// Valeur affichée.
  final String value;

  /// Met la ligne en valeur (gras, couleur principale).
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: textTheme.bodyMedium),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Flexible(
            child: Text(
              value,
              style: isHighlighted
                  ? textTheme.titleMedium?.copyWith(color: AppColors.primary)
                  : textTheme.titleMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}