import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/payment.dart';
import '../../data/models/sale.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/amount_text.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_title.dart';
import 'client_detail_view_model.dart';

/// Profil client : identité, totaux, historique des ventes et des paiements.
class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  /// Identifiant du client affiché.
  final int clientId;

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();

    return ChangeNotifierProvider<ClientDetailViewModel>(
      create: (BuildContext context) => ClientDetailViewModel(
        clientRepository: dependencies.clientRepository,
        saleRepository: dependencies.saleRepository,
        paymentRepository: dependencies.paymentRepository,
        clientId: clientId,
      ),
      child: const _ClientDetailView(),
    );
  }
}

class _ClientDetailView extends StatefulWidget {
  const _ClientDetailView();

  @override
  State<_ClientDetailView> createState() => _ClientDetailViewState();
}

class _ClientDetailViewState extends State<_ClientDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClientDetailViewModel>().load();
    });
  }

  /// Ouvre la saisie d'un paiement et recharge le profil.
  Future<void> _addPayment() async {
    final ClientDetailViewModel viewModel = context
        .read<ClientDetailViewModel>();

    if (viewModel.credit <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Ce client n\'a aucun crédit à récupérer.'),
          ),
        );
      return;
    }

    final int? amount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius),
        ),
      ),
      builder: (BuildContext sheetContext) =>
          _PaymentSheet(maximum: viewModel.credit),
    );

    if (amount == null || !mounted) return;

    final String? error = await viewModel.recordPayment(amount);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Paiement de ${Formatters.amount(amount)} enregistré.',
          ),
          backgroundColor: error == null ? AppColors.success : AppColors.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ClientDetailViewModel viewModel = context
        .watch<ClientDetailViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil du client')),
      body: SafeArea(child: _buildBody(context, viewModel)),
    );
  }

  Widget _buildBody(BuildContext context, ClientDetailViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return const LoadingView(message: 'Chargement du profil...');
      case ViewStatus.error:
        return ErrorView(
          message:
              viewModel.errorMessage ?? 'Impossible de charger ce client.',
          onRetry: viewModel.load,
        );
      case ViewStatus.empty:
      case ViewStatus.success:
        return _Content(viewModel: viewModel, onAddPayment: _addPayment);
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.viewModel, required this.onAddPayment});

  final ClientDetailViewModel viewModel;
  final VoidCallback onAddPayment;

  @override
  Widget build(BuildContext context) {
    final client = viewModel.client;
    if (client == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: context.appPalette.primarySoft,
                    child: Text(
                      client.name.isNotEmpty
                          ? client.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: AppTextStyles.h3.copyWith(
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
                          style: AppTextStyles.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          client.phone?.isNotEmpty == true
                              ? client.phone!
                              : 'Sans téléphone',
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (client.address?.isNotEmpty == true) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: context.appPalette.secondaryText,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: Text(
                        client.address!,
                        style: AppTextStyles.small,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total achats',
                value: Formatters.amount(viewModel.totalPurchases),
                icon: Icons.shopping_bag_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: _MetricCard(
                label: 'Crédit actuel',
                value: Formatters.amount(viewModel.credit),
                icon: Icons.account_balance_wallet_outlined,
                color: viewModel.credit > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        AppButton(
          label: 'Ajouter un paiement',
          icon: Icons.payments_outlined,
          onPressed: onAddPayment,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const SectionTitle(title: 'Historique des ventes'),
        const SizedBox(height: AppDimensions.spacingMd),
        if (viewModel.sales.isEmpty)
          const AppCard(
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aucune vente',
              message: 'Ce client n\'a pas encore acheté de charbon.',
            ),
          )
        else
          for (final Sale sale in viewModel.sales)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingMd,
              ),
              child: AppCard(
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.saleDetail,
                  arguments: sale.id,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${Formatters.quantity(sale.quantity)} · '
                            '${Formatters.date(sale.createdAt ?? DateTime.now())}',
                            style: AppTextStyles.bodyBold,
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          Text(
                            'Payé : ${Formatters.amount(sale.paidAmount)}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AmountText(
                          amount: Formatters.amount(sale.totalAmount),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          sale.creditAmount > 0
                              ? 'Reste ${Formatters.amount(sale.creditAmount)}'
                              : 'Soldée',
                          style: AppTextStyles.captionBold.copyWith(
                            color: sale.creditAmount > 0
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: AppDimensions.spacingMd),
        const SectionTitle(title: 'Historique des paiements'),
        const SizedBox(height: AppDimensions.spacingMd),
        if (viewModel.payments.isEmpty)
          const AppCard(
            child: EmptyState(
              icon: Icons.payments_outlined,
              title: 'Aucun paiement',
              message: 'Aucun règlement n\'a encore été enregistré.',
            ),
          )
        else
          for (final Payment payment in viewModel.payments)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingMd,
              ),
              child: AppCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Text(
                        Formatters.date(
                          payment.createdAt ?? DateTime.now(),
                        ),
                        style: AppTextStyles.small,
                      ),
                    ),
                    AmountText(
                      amount: Formatters.amount(payment.amount),
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: AppDimensions.spacingLg),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
          AmountText(
            amount: value,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Feuille de saisie du montant d'un paiement.
class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.maximum});

  /// Crédit restant : borne haute du montant saisi.
  final int maximum;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final int amount = AmountField.parse(_controller.text);

    if (amount <= 0) {
      setState(() => _error = 'Saisissez un montant supérieur à 0.');
      return;
    }
    if (amount > widget.maximum) {
      setState(
        () => _error =
            'Le montant dépasse le crédit restant '
            '(${Formatters.amount(widget.maximum)}).',
      );
      return;
    }
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.screenPadding,
        right: AppDimensions.screenPadding,
        top: AppDimensions.spacingLg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            AppDimensions.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Enregistrer un paiement', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Crédit restant : ${Formatters.amount(widget.maximum)}',
            style: AppTextStyles.small,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          AmountField(
            label: 'Montant reçu',
            controller: _controller,
            autofocus: true,
            errorText: _error,
            helperText: 'Maximum : ${Formatters.amount(widget.maximum)}',
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          AppButton(
            label: 'Enregistrer le paiement',
            icon: Icons.check,
            onPressed: _submit,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          AppOutlinedButton(
            label: 'Annuler',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}