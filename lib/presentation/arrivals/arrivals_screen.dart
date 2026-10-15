import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/di/app_dependencies.dart';
import '../../../core/l10n/app_strings.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'arrival_form_screen.dart';
import 'arrivals_view_model.dart';

/// Historique des arrivages de charbon.
class ArrivalsScreen extends StatefulWidget {
  const ArrivalsScreen({super.key});

  @override
  State<ArrivalsScreen> createState() => _ArrivalsScreenState();
}

class _ArrivalsScreenState extends State<ArrivalsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ArrivalsViewModel>().load();
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
      context.read<ArrivalsViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ArrivalsViewModel viewModel = context.watch<ArrivalsViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('nav.arrivals'))),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'arrivals-fab',
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

  Widget _buildBody(BuildContext context, ArrivalsViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return LoadingView(message: context.t('common.loadingData'));
      case ViewStatus.error:
        return ErrorView(
          message:
              viewModel.errorMessage ?? 'Impossible de charger les arrivages.',
          onRetry: viewModel.load,
        );
      case ViewStatus.empty:
        return EmptyState(
          icon: Icons.local_shipping_outlined,
          title: 'Aucun arrivage',
          message:
              'Enregistrez votre premier arrivage pour commencer à vendre '
              'du charbon.',
          actionLabel: context.t('home.newArrival'),
          onAction: () async {
            await Navigator.of(context).pushNamed(AppRoutes.arrivalForm);
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
                viewModel.arrivals.length + (viewModel.isLoadingMore ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppDimensions.spacingMd),
            itemBuilder: (BuildContext context, int index) {
              if (index >= viewModel.arrivals.length) {
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
              return ArrivalCard(arrival: viewModel.arrivals[index]);
            },
          ),
        );
    }
  }
}

/// Fournit le ViewModel des arrivages.
class ArrivalsViewModelProvider extends StatelessWidget {
  const ArrivalsViewModelProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();
    return ChangeNotifierProvider<ArrivalsViewModel>(
      create: (BuildContext context) =>
          ArrivalsViewModel(arrivalRepository: dependencies.arrivalRepository),
      child: child,
    );
  }
}