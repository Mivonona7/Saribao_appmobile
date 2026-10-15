import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/app_dependencies.dart';
import '../../../core/l10n/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/database_tables.dart';
import '../../data/models/sale.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/amount_text.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'sales_view_model.dart';

/// Carte d'une vente dans l'historique.
class SaleCard extends StatelessWidget {
  const SaleCard({super.key, required this.sale, required this.clientName, this.onTap});

  /// Vente affichée.
  final Sale sale;

  /// Nom du client, `null` pour une vente comptoir.
  final String? clientName;

  /// Action au tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isPaid = sale.paymentStatus == PaymentStatus.paid;
    final bool isCredit = sale.paymentStatus == PaymentStatus.credit;
    final Color statusColor = isPaid
        ? AppColors.success
        : isCredit
        ? AppColors.error
        : AppColors.warning;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  clientName ?? 'Client comptoir',
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  '${Formatters.quantity(sale.quantity)} × '
                  '${Formatters.amount(sale.unitPrice)} · '
                  '${Formatters.dateTime(sale.createdAt ?? DateTime.now())}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
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
                    // Le libellé doit pouvoir rétrécir : sinon la ligne déborde
                    // sur les petits écrans quand le reste à payer s'affiche.
                    Flexible(
                      child: Text(
                        PaymentStatus.label(sale.paymentStatus),
                        style: AppTextStyles.captionBold.copyWith(
                          color: statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (sale.creditAmount > 0) ...[
                      const SizedBox(width: AppDimensions.spacingSm),
                      Flexible(
                        child: Text(
                          'Reste ${Formatters.amount(sale.creditAmount)}',
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          AmountText(
            amount: Formatters.amount(sale.totalAmount),
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }
}

/// Écran Ventes : historique paginé et accès à la nouvelle vente.
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SalesViewModel>().load();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining < 300) {
      context.read<SalesViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final SalesViewModel viewModel = context.watch<SalesViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('nav.sales'))),
      floatingActionButton: FloatingActionButton.extended(
        // Les onglets vivent tous dans le même IndexedStack : sans tag unique,
        // les quatre FAB partagent le tag par défaut et le HeroAnimator échoue.
        heroTag: 'sales-fab',
        onPressed: () async {
          await Navigator.of(context).pushNamed(AppRoutes.saleForm);
          if (mounted) await viewModel.load();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Vendre'),
      ),
      body: SafeArea(child: _buildBody(context, viewModel)),
    );
  }

  Widget _buildBody(BuildContext context, SalesViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return LoadingView(message: context.t('common.loadingData'));
      case ViewStatus.error:
        return ErrorView(
          message:
              viewModel.errorMessage ?? 'Impossible de charger les ventes.',
          onRetry: viewModel.load,
        );
      case ViewStatus.empty:
        return EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Aucune vente',
          message:
              'Enregistrez votre première vente : choisissez un client, '
              'le nombre de sacs et le prix.',
          actionLabel: context.t('home.newSale'),
          onAction: () async {
            await Navigator.of(context).pushNamed(AppRoutes.saleForm);
            if (mounted) await viewModel.load();
          },
        );
      case ViewStatus.success:
        return RefreshIndicator(
          onRefresh: viewModel.load,
          color: AppColors.primary,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.spacingLg,
              AppDimensions.screenPadding,
              AppDimensions.spacingXxl,
            ),
            itemCount:
                viewModel.sales.length + (viewModel.isLoadingMore ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppDimensions.spacingMd),
            itemBuilder: (BuildContext context, int index) {
              if (index >= viewModel.sales.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingLg),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              final Sale sale = viewModel.sales[index];
              return SaleCard(
                sale: sale,
                clientName: viewModel.clientNameOf(sale),
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    AppRoutes.saleDetail,
                    arguments: sale.id,
                  );
                  await viewModel.load();
                },
              );
            },
          ),
        );
    }
  }
}

/// Fournit le ViewModel de l'historique des ventes.
class SalesViewModelProvider extends StatelessWidget {
  const SalesViewModelProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();
    return ChangeNotifierProvider<SalesViewModel>(
      create: (BuildContext context) => SalesViewModel(
        saleRepository: dependencies.saleRepository,
        clientRepository: dependencies.clientRepository,
      ),
      child: child,
    );
  }
}