import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/client.dart';
import '../widgets/amount_text.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/section_title.dart';
import '../widgets/stock_indicator.dart';
import 'sale_form_view_model.dart';

/// Formulaire de nouvelle vente.
///
/// Formulaire uniquement : `SingleChildScrollView` pour que le clavier ne
/// masque jamais les champs. Toute la logique vit dans le ViewModel.
class SaleFormScreen extends StatelessWidget {
  const SaleFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();

    return ChangeNotifierProvider<SaleFormViewModel>(
      create: (BuildContext context) => SaleFormViewModel(
        saleRepository: dependencies.saleRepository,
        clientRepository: dependencies.clientRepository,
      ),
      child: const _SaleFormView(),
    );
  }
}

class _SaleFormView extends StatefulWidget {
  const _SaleFormView();

  @override
  State<_SaleFormView> createState() => _SaleFormViewState();
}

class _SaleFormViewState extends State<_SaleFormView> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _clientSearchController = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    context.read<SaleFormViewModel>().loadStock();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _paidController.dispose();
    _clientSearchController.dispose();
    super.dispose();
  }

  /// Demande confirmation puis enregistre la vente.
  Future<void> _submit(SaleFormViewModel viewModel) async {
    if (!viewModel.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Vérifiez les champs en rouge.')),
        );
      return;
    }

    final bool confirmed = await showConfirmationDialog(
      context,
      title: 'Confirmer la vente ?',
      message:
          'Vérifiez les détails avant d\'enregistrer. Cette action diminuera '
          'votre stock.',
      confirmLabel: 'Confirmer',
      details: <Widget>[
        ConfirmationDetailRow(
          label: 'Client',
          value: viewModel.selectedClient?.name ?? 'Client comptoir',
        ),
        ConfirmationDetailRow(
          label: 'Quantité',
          value: Formatters.quantity(viewModel.quantity),
        ),
        ConfirmationDetailRow(
          label: 'Prix par sac',
          value: Formatters.amount(viewModel.unitPrice),
        ),
        ConfirmationDetailRow(
          label: 'Paiement',
          value: Formatters.amount(viewModel.paidAmount),
        ),
        ConfirmationDetailRow(
          label: 'Total',
          value: Formatters.amount(viewModel.total),
          isHighlighted: true,
        ),
      ],
    );

    if (!confirmed || !mounted) return;

    final String? error = await viewModel.submit();
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      return;
    }

    await _showSuccessSheet(viewModel);
  }

  /// Confirmation visuelle après enregistrement, avec le stock restant.
  Future<void> _showSuccessSheet(SaleFormViewModel viewModel) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appPalette.surface,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text('Vente enregistrée', style: AppTextStyles.h2),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                Formatters.quantity(viewModel.quantity),
                style: AppTextStyles.amount,
              ),
              AmountText(
                amount: Formatters.amount(viewModel.total),
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              StockIndicator(quantity: viewModel.availableStock),
              Text(
                'Stock restant : ${viewModel.availableStock} sacs',
                style: AppTextStyles.small,
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              AppButton(
                label: 'Terminer',
                icon: Icons.check,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final SaleFormViewModel viewModel = context.watch<SaleFormViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle vente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StockBanner(viewModel: viewModel),
              const SizedBox(height: AppDimensions.spacingLg),
              const SectionTitle(title: 'Client'),
              const SizedBox(height: AppDimensions.spacingMd),
              _ClientPicker(
                viewModel: viewModel,
                searchController: _clientSearchController,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              const SectionTitle(title: 'Nombre de sacs'),
              const SizedBox(height: AppDimensions.spacingMd),
              QuantitySelector(
                value: viewModel.quantity,
                max: viewModel.availableStock > 0
                    ? viewModel.availableStock
                    : null,
                onChanged: viewModel.setQuantity,
              ),
              if (viewModel.quantityError != null)
                _FieldError(message: viewModel.quantityError!),
              if (viewModel.exceedsStock)
                const _FieldError(
                  message:
                      'Vous ne pouvez pas vendre plus de sacs que le stock '
                      'disponible.',
                ),
              const SizedBox(height: AppDimensions.spacingLg),
              AmountField(
                label: 'Prix par sac',
                controller: _priceController,
                errorText: viewModel.priceError,
                textInputAction: TextInputAction.next,
                onChanged: (String value) =>
                    viewModel.setUnitPrice(AmountField.parse(value)),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              const SectionTitle(title: 'Paiement'),
              const SizedBox(height: AppDimensions.spacingMd),
              _PaymentModeSelector(viewModel: viewModel),
              if (viewModel.mode == SalePaymentMode.partial) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                AmountField(
                  label: 'Montant payé maintenant',
                  controller: _paidController,
                  helperText: 'Total : ${Formatters.amount(viewModel.total)}',
                  textInputAction: TextInputAction.done,
                  onChanged: (String value) =>
                      viewModel.setPaidAmount(AmountField.parse(value)),
                ),
              ],
              const SizedBox(height: AppDimensions.spacingLg),
              _TotalCard(viewModel: viewModel),
              const SizedBox(height: AppDimensions.spacingXl),
              AppButton(
                label: 'Valider la vente',
                icon: Icons.check,
                isLoading: viewModel.isSaving,
                onPressed: () => _submit(viewModel),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBanner extends StatelessWidget {
  const _StockBanner({required this.viewModel});

  final SaleFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.cardPadding,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              'Stock disponible : ${viewModel.availableStock} sacs',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientPicker extends StatefulWidget {
  const _ClientPicker({required this.viewModel, required this.searchController});

  final SaleFormViewModel viewModel;
  final TextEditingController searchController;

  @override
  State<_ClientPicker> createState() => _ClientPickerState();
}

class _ClientPickerState extends State<_ClientPicker> {
  @override
  Widget build(BuildContext context) {
    final SaleFormViewModel viewModel = widget.viewModel;
    final Client? selected = viewModel.selectedClient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selected == null)
          AppTextField(
            label: 'Rechercher ou créer un client',
            controller: widget.searchController,
            hintText: 'Tapez un nom',
            prefixIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onChanged: viewModel.searchClients,
          )
        else
          AppCard(
            color: context.appPalette.primarySoft,
            borderColor: AppColors.primary,
            child: Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Text(
                    selected.name,
                    style: AppTextStyles.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    viewModel.selectClient(null);
                    widget.searchController.clear();
                    viewModel.searchClients('');
                  },
                  icon: const Icon(Icons.close),
                  tooltip: 'Changer de client',
                ),
              ],
            ),
          ),
        if (viewModel.clientError != null)
          _FieldError(message: viewModel.clientError!),
        if (selected == null && viewModel.searchResults.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingSm),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: context.appPalette.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: context.appPalette.border),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                final Client client = viewModel.searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.appPalette.primarySoft,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(client.name),
                  subtitle: client.phone?.isNotEmpty == true
                      ? Text(client.phone!)
                      : null,
                  onTap: () {
                    viewModel.selectClient(client);
                    widget.searchController.clear();
                    viewModel.searchClients('');
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.spacingSm),
        AppOutlinedButton(
          label: 'Ajouter un client',
          icon: Icons.person_add_alt,
          onPressed: () async {
            final bool? created = await Navigator.of(
              context,
            ).pushNamed('/client/new');
            if (created == true) {
              await viewModel.searchClients('');
            }
          },
        ),
      ],
    );
  }
}

class _PaymentModeSelector extends StatelessWidget {
  const _PaymentModeSelector({required this.viewModel});

  final SaleFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: 'Payé',
            icon: Icons.check_circle_outline,
            selected: viewModel.mode == SalePaymentMode.paid,
            color: AppColors.success,
            onTap: () =>
                viewModel.setMode(SalePaymentMode.paid),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _ModeChip(
            label: 'Crédit',
            icon: Icons.schedule,
            selected: viewModel.mode == SalePaymentMode.credit,
            color: AppColors.warning,
            onTap: () =>
                viewModel.setMode(SalePaymentMode.credit),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _ModeChip(
            label: 'Partiel',
            icon: Icons.pie_chart_outline,
            selected: viewModel.mode == SalePaymentMode.partial,
            color: AppColors.primary,
            onTap: () =>
                viewModel.setMode(SalePaymentMode.partial),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Paiement $label',
      child: Material(
        color: selected ? color : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          side: BorderSide(color: color),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.white : color,
                  size: 22,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  label,
                  style: AppTextStyles.captionBold.copyWith(
                    color: selected ? AppColors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.viewModel});

  final SaleFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: context.appPalette.primarySoft,
      borderColor: AppColors.primary,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: AppTextStyles.captionBold),
              Text(
                Formatters.quantity(viewModel.quantity),
                style: AppTextStyles.small,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montant', style: AppTextStyles.h3),
              Flexible(
                child: AmountText(
                  amount: Formatters.amount(viewModel.total),
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          if (viewModel.credit > 0) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text('Reste à payer', style: AppTextStyles.small),
                  ],
                ),
                Text(
                  Formatters.amount(viewModel.credit),
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}