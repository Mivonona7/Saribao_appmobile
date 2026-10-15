import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/amount_text.dart';
import '../widgets/app_card.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_title.dart';
import 'reports_view_model.dart';

/// Rapports : indicateurs calculés depuis SQLite sur une période choisie.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();

    return ChangeNotifierProvider<ReportsViewModel>(
      create: (BuildContext context) => ReportsViewModel(
        saleRepository: dependencies.saleRepository,
        arrivalRepository: dependencies.arrivalRepository,
        paymentRepository: dependencies.paymentRepository,
      ),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReportsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReportsViewModel viewModel = context.watch<ReportsViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('reports.title'))),
      body: SafeArea(child: _buildBody(context, viewModel)),
    );
  }

  Widget _buildBody(BuildContext context, ReportsViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return LoadingView(message: context.t('common.loadingData'));
      case ViewStatus.error:
        return ErrorView(
          message:
              viewModel.errorMessage ?? 'Impossible de calculer les rapports.',
          onRetry: viewModel.load,
        );
      case ViewStatus.empty:
      case ViewStatus.success:
        return RefreshIndicator(
          onRefresh: viewModel.load,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            children: [
SectionTitle(
                title: context.t('reports.period'),
                subtitle: context.t('reports.periodSubtitle'),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Wrap(
                spacing: AppDimensions.spacingSm,
                runSpacing: AppDimensions.spacingSm,
                children: ReportPeriod.values
                    .map(
                      (ReportPeriod period) => _PeriodChip(
                        period: period,
                        selected: viewModel.period == period,
                        onTap: () => viewModel.selectPeriod(period),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              SectionTitle(title: context.t('nav.sales')),
              const SizedBox(height: AppDimensions.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: context.t('reports.unitsSold'),
                      value: Formatters.quantity(
                        viewModel.summary?.bagsSold ?? 0,
                      ),
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: _Metric(
                      label: context.t('reports.revenue'),
                      value: Formatters.amount(
                        viewModel.summary?.revenue ?? 0,
                      ),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: context.t('sale.amountPaid'),
                      value: Formatters.amount(
                        viewModel.summary?.collected ?? 0,
                      ),
                      icon: Icons.payments_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: _Metric(
                      label: context.t('reports.purchases'),
                      value: Formatters.amount(viewModel.purchases),
                      icon: Icons.local_shipping_outlined,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              AppCard(
                borderColor: viewModel.outstandingCredit > 0
                    ? AppColors.warning.withValues(alpha: 0.45)
                    : context.appPalette.border,
                child: Row(
                  children: [
                    Icon(
                      viewModel.outstandingCredit > 0
                          ? Icons.account_balance_wallet_outlined
                          : Icons.check_circle_outline,
                      color: viewModel.outstandingCredit > 0
                          ? AppColors.warning
                          : AppColors.success,
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
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          AmountText(
                            amount: Formatters.amount(
                              viewModel.outstandingCredit,
                            ),
                            style: AppTextStyles.amount,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        );
    }
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.period,
    required this.selected,
    required this.onTap,
  });

  final ReportPeriod period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          side: const BorderSide(color: AppColors.primary),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingMd,
            ),
            child: Text(
              period.label,
              style: AppTextStyles.captionBold.copyWith(
                color: selected ? AppColors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.captionBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          AmountText(amount: value, style: AppTextStyles.h3, color: color),
        ],
      ),
    );
  }
}