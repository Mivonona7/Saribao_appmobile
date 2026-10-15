import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Niveau de stock : normal, bas, critique, ou rupture.
enum StockLevel {
  /// Stock confortable.
  normal,

  /// Stock qui commence à baisser.
  low,

  /// Stock critique.
  critical,

  /// Aucun sac disponible.
  empty,
}

/// Pastille d'état du stock : icône + libellé + couleur.
///
/// L'information n'est jamais portée par la couleur seule.
class StockIndicator extends StatelessWidget {
  const StockIndicator({
    super.key,
    required this.quantity,
    this.level,
    this.color,
  });

  /// Quantité de sacs actuellement en stock.
  final int quantity;

  /// Niveau forcé. Calculé automatiquement si absent.
  final StockLevel? level;

  /// Couleur forcée. Déduite du niveau si absente.
  final Color? color;

  /// Détermine le niveau d'un stock à partir d'une quantité.
  static StockLevel levelFor(int quantity) {
    if (quantity <= 0) return StockLevel.empty;
    if (quantity < AppConstants.lowStockThreshold) return StockLevel.critical;
    if (quantity < AppConstants.mediumStockThreshold) return StockLevel.low;
    return StockLevel.normal;
  }

  /// Couleur associée à un niveau de stock.
  static Color colorFor(StockLevel level) {
    switch (level) {
      case StockLevel.normal:
        return AppColors.success;
      case StockLevel.low:
        return AppColors.warning;
      case StockLevel.critical:
      case StockLevel.empty:
        return AppColors.error;
    }
  }

  /// Libellé lisible d'un niveau de stock.
  static String labelFor(StockLevel level) {
    switch (level) {
      case StockLevel.normal:
        return 'Stock normal';
      case StockLevel.low:
        return 'Stock bas';
      case StockLevel.critical:
        return 'Stock critique';
      case StockLevel.empty:
        return 'Rupture de stock';
    }
  }

  /// Icône associée à un niveau de stock.
  static IconData iconFor(StockLevel level) {
    switch (level) {
      case StockLevel.normal:
        return Icons.check_circle;
      case StockLevel.low:
        return Icons.warning_amber_rounded;
      case StockLevel.critical:
        return Icons.error_outline;
      case StockLevel.empty:
        return Icons.remove_shopping_cart_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final StockLevel resolvedLevel = level ?? levelFor(quantity);
    final Color resolvedColor = color ?? colorFor(resolvedLevel);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconFor(resolvedLevel),
          size: 16,
          color: resolvedColor,
          semanticLabel: labelFor(resolvedLevel),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Flexible(
          child: Text(
            labelFor(resolvedLevel),
            style: AppTextStyles.captionBold.copyWith(color: resolvedColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}