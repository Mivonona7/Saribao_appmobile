import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/app_dependencies.dart';
import '../../../core/l10n/app_strings.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/stock_indicator.dart';
import 'stock_view_model.dart';
import 'widgets/movement_tile.dart';

/// Écran Stock : quantité disponible et historique des mouvements.
///
/// L'historique est paginé pour rester fluide avec des milliers de ventes.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockViewModel>().load();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Charge la page suivante quand on approche du bas de la liste.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining < 300) {
      context.read<StockViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final StockViewModel viewModel = context.watch<StockViewModel>();

    return Scaffold(
appBar: AppBar(
        title: Text(context.t('nav.stock')),
        actions: [
          IconButton(
            tooltip: context.t('nav.arrivals'),
            icon: const Icon(Icons.history_outlined),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.arrivals),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'stock-fab',
        onPressed: () async {
          await Navigator.of(context).pushNamed(AppRoutes.arrivalForm);
          if (mounted) await viewModel.load();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.local_shipping_outlined),
        label: const Text('Arrivage'),
      ),
      body: SafeArea(child: _buildBody(context, viewModel)),
    );
  }

  Widget _buildBody(BuildContext context, StockViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return LoadingView(message: context.t('common.loadingData'));
      case ViewStatus.error:
        return ErrorView(
          message:
              viewModel.errorMessage ??
              'Impossible de charger le stock.',
          onRetry: viewModel.load,
        );
      case ViewStatus.empty:
      case ViewStatus.success:
        return RefreshIndicator(
          onRefresh: viewModel.load,
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  AppDimensions.spacingLg,
                  AppDimensions.screenPadding,
                  AppDimensions.spacingMd,
                ),
                sliver: SliverToBoxAdapter(
                  child: _StockHeader(quantity: viewModel.stockQuantity),
                ),
              ),
              if (viewModel.movements.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Aucun mouvement',
                    message:
                        'Enregistrez un arrivage pour ajouter vos premiers '
                        'sacs de charbon.',
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding,
                    AppDimensions.spacingMd,
                    AppDimensions.screenPadding,
                    AppDimensions.spacingMd,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      context.t('stock.movements').toUpperCase(),
                      style: AppTextStyles.captionBold,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding,
                  ),
                  sliver: SliverList.separated(
                    itemCount: viewModel.movements.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: AppDimensions.spacingMd),
                    itemBuilder: (BuildContext context, int index) =>
                        MovementTile(
                          movement: viewModel.movements[index],
                        ),
                  ),
                ),
                if (viewModel.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingLg),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spacingXl),
                  ),
              ],
              // Espace pour ne pas masquer la dernière ligne sous le bouton.
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.spacingXxl),
              ),
            ],
          ),
        );
    }
  }
}

/// Fournit le ViewModel de l'écran Stock.
class StockViewModelProvider extends StatelessWidget {
  const StockViewModelProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();
    return ChangeNotifierProvider<StockViewModel>(
      create: (BuildContext context) =>
          StockViewModel(stockRepository: dependencies.stockRepository),
      child: child,
    );
  }
}

class _StockHeader extends StatelessWidget {
  const _StockHeader({required this.quantity});

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
            'STOCK ACTUEL',
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
                'SACS',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          StockIndicator(quantity: quantity, color: AppColors.white),
        ],
      ),
    );
  }
}