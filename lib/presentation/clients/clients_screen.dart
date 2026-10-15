import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/di/app_dependencies.dart';
import '../../../core/l10n/app_strings.dart';
import '../../data/models/client.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'clients_view_model.dart';
import 'widgets/client_card.dart';

/// Écran Clients : recherche rapide et liste paginée.
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClientsViewModel>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ClientsViewModel viewModel = context.watch<ClientsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('nav.clients')),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.reports,
            ),
            icon: const Icon(Icons.insights_outlined),
            tooltip: context.t('nav.reports'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'clients-fab',
        onPressed: () async {
          await Navigator.of(context).pushNamed(AppRoutes.clientForm);
          if (mounted) await viewModel.load();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        tooltip: context.t('client.new'),
        child: const Icon(Icons.person_add_alt),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                AppDimensions.spacingLg,
                AppDimensions.screenPadding,
                AppDimensions.spacingMd,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: viewModel.search,
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: context.t('client.searchHint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            viewModel.search('');
                          },
                          icon: const Icon(Icons.close),
                          tooltip: context.t('common.close'),
                        ),
                ),
              ),
            ),
            Expanded(child: _buildBody(context, viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ClientsViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return LoadingView(message: context.t('common.loadingData'));
      case ViewStatus.error:
        return ErrorView(
          message:
              viewModel.errorMessage ?? 'Impossible de charger les clients.',
          onRetry: viewModel.load,
        );
      case ViewStatus.empty:
        return EmptyState(
          icon: Icons.people_outline_rounded,
          title: viewModel.query.isEmpty
              ? 'Aucun client'
              : 'Aucun résultat',
          message: viewModel.query.isEmpty
              ? 'Ajoutez vos clients pour suivre leurs achats et leurs crédits.'
              : 'Aucun client ne correspond à « ${viewModel.query} ».',
          actionLabel: viewModel.query.isEmpty ? 'Ajouter un client' : null,
          onAction: viewModel.query.isEmpty
              ? () => Navigator.of(context).pushNamed(AppRoutes.clientForm)
              : null,
        );
      case ViewStatus.success:
        return RefreshIndicator(
          onRefresh: viewModel.load,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              0,
              AppDimensions.screenPadding,
              // Espace pour le bouton flottant.
              AppDimensions.spacingXxl,
            ),
            itemCount: viewModel.clients.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppDimensions.spacingMd),
            itemBuilder: (BuildContext context, int index) {
              final Client client = viewModel.clients[index];
              return ClientCard(
                client: client,
                credit: viewModel.creditOf(client.id ?? 0),
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    AppRoutes.clientDetail,
                    arguments: client.id,
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

/// ViewModel Clients, fourni à l'écran via `provider`.
class ClientsViewModelProvider extends StatelessWidget {
  const ClientsViewModelProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();
    return ChangeNotifierProvider<ClientsViewModel>(
      create: (BuildContext context) => ClientsViewModel(
        clientRepository: dependencies.clientRepository,
        paymentRepository: dependencies.paymentRepository,
      ),
      child: child,
    );
  }
}