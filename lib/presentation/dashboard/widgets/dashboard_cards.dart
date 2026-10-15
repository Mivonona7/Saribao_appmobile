import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/sale.dart';
import '../../../data/database/database_tables.dart';
import '../../widgets/amount_text.dart';
import '../../widgets/stock_indicator.dart';
import '../dashboard_view_model.dart';

/// Carte principale du dashboard : stock disponible en gros caractères.
class StockCard extends StatelessWidget {
  const StockCard({super.key, required this.quantity});

  /// Nombre de sacs en stock.
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF8B7BF0)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('home.stockAvailable'),
            style: AppTextStyles.captionBold.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$quantity',
                style: AppTextStyles.displayNumber,
                semanticsLabel: '$quantity sacs en stock',
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                context.t('common.sacs').toUpperCase(),
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingXs,
              ),
              child: StockIndicator(quantity: quantity, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte des crédits restant à récupérer, avec icône d'alerte.
class CreditCard extends StatelessWidget {
  const CreditCard({super.key, required this.amount, this.onTap});

  /// Total des crédits ouverts, en ariary.
  final int amount;

  /// Rend la carte cliquable pour ouvrir le suivi des crédits.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimensions.radius);
    final bool hasCredit = amount > 0;

    return Material(
      color: context.appPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: hasCredit
              ? AppColors.warning.withValues(alpha: 0.45)
              : context.appPalette.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasCredit
                      ? AppColors.warning.withValues(alpha: 0.14)
                      : AppColors.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Icon(
                  hasCredit
                      ? Icons.account_balance_wallet_outlined
                      : Icons.check_circle_outline,
                  color: hasCredit ? AppColors.warning : AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.t('home.creditsToCollect'),
                      style: AppTextStyles.captionBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    AmountText(
                      amount: Formatters.amount(amount),
                      style: AppTextStyles.amount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ligne d'une vente récente dans « Dernières ventes ».
class RecentSaleTile extends StatelessWidget {
  const RecentSaleTile({super.key, required this.item, this.onTap});

  /// Vente à afficher, avec son client.
  final RecentSaleItem item;

  /// Action au tap (ouverture du détail de la vente).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Sale sale = item.sale;
    final bool isPaid = sale.paymentStatus == PaymentStatus.paid;
    final bool isCredit = sale.paymentStatus == PaymentStatus.credit;
    final Color statusColor = isPaid
        ? AppColors.success
        : isCredit
        ? AppColors.error
        : AppColors.warning;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.clientName,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      '${Formatters.quantity(sale.quantity)} · '
                      '${Formatters.date(sale.createdAt ?? DateTime.now())}',
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
                  AmountText(amount: Formatters.amount(sale.totalAmount)),
                  const SizedBox(height: AppDimensions.spacingXs),
                  // Statut porté par icône + texte, jamais par la couleur seule.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid
                            ? Icons.check_circle
                            : isCredit
                            ? Icons.error_outline
                            : Icons.schedule,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Text(
                        PaymentStatus.label(sale.paymentStatus),
                        style: AppTextStyles.captionBold.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}