import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Sélecteur de quantité : boutons − / + et saisie directe.
///
/// La valeur ne descend jamais sous [AppConstants.minQuantity].
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = AppConstants.minQuantity,
    this.max,
    this.enabled = true,
  });

  /// Valeur courante.
  final int value;

  /// Notifié à chaque changement.
  final ValueChanged<int> onChanged;

  /// Valeur minimale (1 par défaut).
  final int min;

  /// Valeur maximale, `null` si aucune.
  final int? max;

  /// Active ou désactive les interactions.
  final bool enabled;

  void _increment() {
    final int next = value + 1;
    if (max != null && next > max!) return;
    onChanged(next);
  }

  void _decrement() {
    final int next = value - 1;
    if (next < min) return;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = enabled && value > min;
    final bool canIncrement = enabled && (max == null || value < max!);

    return Row(
      children: [
        _SelectorButton(
          icon: Icons.remove_rounded,
          semanticLabel: 'Diminuer la quantité',
          onPressed: canDecrement ? _decrement : null,
        ),
        Expanded(
          child: Container(
            height: AppDimensions.buttonHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appPalette.primarySoft,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              '$value',
              style: AppTextStyles.amount.copyWith(color: AppColors.primary),
              semanticsLabel: '$value ${AppConstants.pluralUnitLabel}',
            ),
          ),
        ),
        _SelectorButton(
          icon: Icons.add_rounded,
          semanticLabel: 'Augmenter la quantité',
          onPressed: canIncrement ? _increment : null,
        ),
      ],
    );
  }
}

class _SelectorButton extends StatelessWidget {
  const _SelectorButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: AppDimensions.buttonHeight,
        height: AppDimensions.buttonHeight,
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            side: const BorderSide(color: AppColors.primary),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Icon(
              icon,
              size: 24,
              color: onPressed == null
                  ? palette.secondaryText
                  : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}