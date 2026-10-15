import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';

/// Petite carte de statistique : libellé, valeur et icône colorée.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBackgroundColor,
    this.onTap,
  });

  /// Libellé de la statistique.
  final String label;

  /// Valeur affichée, déjà formatée.
  final String value;

  /// Icône représentative.
  final IconData icon;

  /// Couleur de l'icône.
  final Color iconColor;

  /// Fond de la pastille qui contient l'icône. Par défaut, la variante douce
  /// du violet fournie par le thème actif.
  final Color? iconBackgroundColor;

  /// Rend la carte cliquable (navigation vers un détail).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor ?? palette.primarySoft,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: AppTextStyles.captionBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                value,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}