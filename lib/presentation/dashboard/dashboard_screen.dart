import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_title.dart';
import '../widgets/stat_card.dart';
import 'dashboard_view_model.dart';
import 'widgets/dashboard_cards.dart';

/// Écran d'accueil : état de l'activité et accès rapides.
///
/// Contenu mixte (en-tête, grille, boutons, liste) : `CustomScrollView` avec
/// des slivers évite tout `ListView` imbriqué dans un `SingleChildScrollView`.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DashboardViewModel>().load();
    });
  }

  /// Rafraîchit le dashboard, par exemple au retour d'une vente.
  Future<void> _reload() async {
    await context.read<DashboardViewModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final DashboardViewModel viewModel = context
        .watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppDimensions.screenPadding,
        title: const Row(
          children: [
            AppLogo(size: 36, showBackground: false),
            SizedBox(width: AppDimensions.spacingSm),
            Expanded(child: _Greeting()),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.t('nav.settings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
        ],
      ),
      body: SafeArea(child: _buildBody(context, viewModel)),
    );
  }

  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return const LoadingView(message: 'Chargement de vos données...');
      case ViewStatus.error:
        return ErrorView(
          message: viewModel.errorMessage ?? 'Impossible de charger le tableau de bord.',
          onRetry: _reload,
        );
      case ViewStatus.empty:
      case ViewStatus.success:
        return _DashboardContent(viewModel: viewModel, onReload: _reload);
    }
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pas d'emoji dans l'interface : l'accueil est porté par l'icône de
        // la barre d'application, pas par un caractère décoratif.
        Row(
          children: [
            // Le salut malgache est plus long que le français : il doit
            // pouvoir se réduire plutôt que déborder de la barre d'application.
            Flexible(
              child: Text(
                context.t('home.greeting'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            const Icon(
              Icons.waving_hand_outlined,
              size: 18,
              color: AppColors.white,
            ),
          ],
        ),
        Text(
          Formatters.date(DateTime.now()),
          style: const TextStyle(fontSize: 12, color: AppColors.white),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.viewModel, required this.onReload});

  final DashboardViewModel viewModel;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onReload,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.spacingLg,
              AppDimensions.screenPadding,
              AppDimensions.spacingXl,
            ),
            sliver: SliverList.list(
              children: [
                StockCard(quantity: viewModel.stockQuantity),
                const SizedBox(height: AppDimensions.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Ventes du jour',
                        value: Formatters.quantity(
                          viewModel.todaySalesQuantity,
                        ),
                        icon: Icons.shopping_bag_rounded,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: StatCard(
                        label: 'CA du jour',
                        value: Formatters.amount(viewModel.todayRevenue),
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.success,
                        iconBackgroundColor: AppColors.success.withValues(
                          alpha: 0.14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                CreditCard(
                  amount: viewModel.outstandingCredits,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.clients),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                AppButton(
                  label: 'Nouvelle vente',
                  icon: Icons.shopping_cart_rounded,
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(AppRoutes.saleForm);
                    await onReload();
                  },
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                AppOutlinedButton(
                  label: 'Nouvel arrivage',
                  icon: Icons.local_shipping_outlined,
                  onPressed: () async {
                    await Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.arrivalForm);
                    await onReload();
                  },
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                const SectionTitle(
                  title: 'Dernières ventes',
                  subtitle: 'Vos ventes les plus récentes',
                ),
                const SizedBox(height: AppDimensions.spacingMd),
              ],
            ),
          ),
          if (!viewModel.hasSales)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding,
                ),
                child: EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Aucune vente',
                  message:
                      'Enregistrez votre premier arrivage puis votre première '
                      'vente pour voir votre activité ici.',
                  actionLabel: 'Nouvel arrivage',
                  onAction: () async {
                    await Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.arrivalForm);
                    await onReload();
                  },
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding,
              ),
              sliver: SliverList.separated(
                itemCount: viewModel.recentSales.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: AppDimensions.spacingMd),
                itemBuilder: (BuildContext context, int index) {
                  return RecentSaleTile(item: viewModel.recentSales[index]);
                },
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacingXl),
          ),
        ],
      ),
    );
  }
}