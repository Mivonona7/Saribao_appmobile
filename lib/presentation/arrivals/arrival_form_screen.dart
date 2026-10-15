import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/arrival.dart';
import '../../data/repositories/arrival_repository.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/amount_text.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/section_title.dart';

/// ViewModel du formulaire d'arrivage.
class ArrivalFormViewModel extends BaseViewModel {
  ArrivalFormViewModel({required ArrivalRepository arrivalRepository})
    : _arrivalRepository = arrivalRepository;

  final ArrivalRepository _arrivalRepository;

  int _quantity = 10;
  int _purchasePrice = 0;
  String? _quantityError;
  String? _priceError;
  bool _isSaving = false;
  int _stockAfter = 0;

  /// Nombre de sacs reçus.
  int get quantity => _quantity;

  /// Prix d'achat par sac.
  int get purchasePrice => _purchasePrice;

  /// Total calculé : `quantity * purchasePrice`.
  int get total => ArrivalRepository.computeTotal(_quantity, _purchasePrice);

  /// Erreur du champ quantité.
  String? get quantityError => _quantityError;

  /// Erreur du champ prix.
  String? get priceError => _priceError;

  /// `true` pendant l'enregistrement.
  bool get isSaving => _isSaving;

  /// Stock après l'ajout.
  int get stockAfter => _stockAfter;

  /// Change la quantité.
  void setQuantity(int value) {
    _quantity = value < 1 ? 1 : value;
    _quantityError = null;
    safeNotify();
  }

  /// Change le prix d'achat par sac.
  void setPurchasePrice(int value) {
    _purchasePrice = value < 0 ? 0 : value;
    _priceError = null;
    safeNotify();
  }

  /// Valide la saisie.
  bool validate() {
    _quantityError = _quantity < 1 ? 'Au moins 1 sac.' : null;
    _priceError = _purchasePrice < 0 ? 'Prix invalide.' : null;
    safeNotify();
    return _quantityError == null && _priceError == null;
  }

  /// Enregistre l'arrivage. Renvoie un message d'erreur, ou `null` si succès.
  Future<String?> submit({String? supplier}) async {
    if (!validate()) return 'Vérifiez les champs en rouge.';

    _isSaving = true;
    safeNotify();

    try {
      final ArrivalResult result = await _arrivalRepository.createArrival(
        quantity: _quantity,
        purchasePricePerBag: _purchasePrice,
        supplier: supplier,
      );
      _stockAfter = result.stockAfter;
      return null;
    } catch (error) {
      return describeError(error);
    } finally {
      _isSaving = false;
      safeNotify();
    }
  }
}

/// Formulaire de nouvel arrivage.
class ArrivalFormScreen extends StatelessWidget {
  const ArrivalFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();

    return ChangeNotifierProvider<ArrivalFormViewModel>(
      create: (BuildContext context) =>
          ArrivalFormViewModel(arrivalRepository: dependencies.arrivalRepository),
      child: const _ArrivalFormView(),
    );
  }
}

class _ArrivalFormView extends StatefulWidget {
  const _ArrivalFormView();

  @override
  State<_ArrivalFormView> createState() => _ArrivalFormViewState();
}

class _ArrivalFormViewState extends State<_ArrivalFormView> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _quantitySynced = false;

  @override
  void dispose() {
    _priceController.dispose();
    _supplierController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ArrivalFormViewModel viewModel = context
        .read<ArrivalFormViewModel>();

    final String? error = await viewModel.submit(
      supplier: _supplierController.text,
    );
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: context.appPalette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                'Arrivage enregistré',
                style: Theme.of(dialogContext).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                '${viewModel.quantity} sacs ajoutés.',
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                'Stock : ${viewModel.stockAfter} sacs',
                style: Theme.of(dialogContext).textTheme.titleMedium,
              ),
            ],
          ),
          actions: [
            SizedBox(
              height: AppDimensions.buttonHeight,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ArrivalFormViewModel viewModel = context
        .watch<ArrivalFormViewModel>();

    // Garde le champ texte synchronisé avec le sélecteur, sans boucle
    // infinie : le contrôleur n'est écrit que si la valeur diffère.
    if (!_quantitySynced ||
        QuantityField.parse(_quantityController.text) != viewModel.quantity) {
      _quantitySynced = true;
      final String text = '${viewModel.quantity}';
      if (_quantityController.text != text) {
        _quantityController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel arrivage')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
            title: 'Combien de sacs sont arrivés ?',
            subtitle: 'Ces sacs seront ajoutés à votre stock.',
          ),
              const SizedBox(height: AppDimensions.spacingLg),
              QuantitySelector(
                value: viewModel.quantity,
                onChanged: viewModel.setQuantity,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              QuantityField(
                label: 'Nombre exact de sacs',
                controller: _quantityController,
                errorText: viewModel.quantityError,
                onChanged: (String value) =>
                    viewModel.setQuantity(QuantityField.parse(value)),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              AmountField(
                label: "Prix d'achat par sac",
                controller: _priceController,
                errorText: viewModel.priceError,
                textInputAction: TextInputAction.next,
                onChanged: (String value) =>
                    viewModel.setPurchasePrice(AmountField.parse(value)),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              AppTextField(
                label: 'Fournisseur (facultatif)',
                controller: _supplierController,
                hintText: 'Ex : Vendor Mahaleo',
                prefixIcon: Icons.storefront_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              AppCard(
                color: context.appPalette.primarySoft,
                borderColor: AppColors.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total à payer', style: AppTextStyles.h3),
                    AmountText(
                      amount: Formatters.amount(viewModel.total),
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              AppButton(
                label: 'Enregistrer l\'arrivage',
                icon: Icons.check,
                isLoading: viewModel.isSaving,
                onPressed: _submit,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte d'un arrivage dans l'historique.
class ArrivalCard extends StatelessWidget {
  const ArrivalCard({super.key, required this.arrival});

  /// Arrivage affiché.
  final Arrival arrival;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${arrival.quantity} sacs',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  [
                    if (arrival.supplier?.isNotEmpty == true)
                      arrival.supplier!,
                    Formatters.date(arrival.createdAt ?? DateTime.now()),
                  ].join(' · '),
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
              AmountText(
                amount: Formatters.amount(arrival.totalPurchaseAmount),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                '${Formatters.amount(arrival.purchasePricePerBag)} / sac',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}