import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/client.dart';

/// Card interactive d'un client, avec son crédit éventuel.
class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    required this.credit,
    this.onTap,
  });

  /// Client affiché.
  final Client client;

  /// Crédit restant du client, en ariary.
  final int credit;

  /// Action au tap (ouverture du profil).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasCredit = credit > 0;
    final BorderRadius radius = BorderRadius.circular(AppDimensions.radius);
    final AppPalette palette = context.appPalette;

    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: palette.primarySoft,
                child: Text(
                  _initials(client.name),
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      client.name,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      client.phone?.isNotEmpty == true
                          ? client.phone!
                          : 'Sans téléphone',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              if (hasCredit)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CRÉDIT',
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      Formatters.amount(credit),
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      'Soldé',
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Initiales affichées dans l'avatar.
  static String _initials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}