import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/stock_movement.dart';

/// Ligne d'historique : mouvement signé, libellé et stock résultant.
class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.movement});

  /// Mouvement à afficher.
  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = movement.isPositive;
    final Color color = isPositive ? AppColors.success : AppColors.error;
    final String prefix = isPositive ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: context.appPalette.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        border: Border.all(color: context.appPalette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              isPositive ? Icons.add_rounded : Icons.remove_rounded,
              color: color,
              size: 22,
              // L'icône double la couleur : l'information reste lisible sans
              // distinguer les couleurs.
              semanticLabel: isPositive ? 'Ajout' : 'Retrait',
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movement.label ?? movement.typeLabel,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  '${movement.typeLabel} · '
                  '${Formatters.dateTime(movement.createdAt ?? DateTime.now())}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$prefix${movement.quantity.abs()}',
                style: AppTextStyles.bodyBold.copyWith(color: color),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Stock : ${movement.stockAfter}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}