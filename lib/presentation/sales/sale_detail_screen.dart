import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/database_tables.dart';
import '../../data/models/payment.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/amount_text.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_title.dart';

/// Détail d'une vente : client, montants et règlements associés.
class SaleDetailScreen extends StatelessWidget {
  const SaleDetailScreen({super.key, required this.saleId});

  /// Identifiant de la vente affichée.
  final int saleId;

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();

    return ChangeNotifierProvider<_SaleDetailViewModel>(
      create: (BuildContext context) => _SaleDetailViewModel(
        saleRepository: dependencies.saleRepository,
        clientRepository: dependencies.clientRepository,
        paymentRepository: dependencies.paymentRepository,
        saleId: saleId,
      ),
      child: const _SaleDetailView(),
    );
  }
}

class _SaleDetailViewModel extends BaseViewModel {
  _SaleDetailViewModel({
    required SaleRepository saleRepository,
    required ClientRepository clientRepository,
    required PaymentRepository paymentRepository,
    required int saleId,
  })  : _saleRepository = saleRepository,
        _clientRepository = clientRepository,
        _paymentRepository = paymentRepository,
        _saleId = saleId;

  final SaleRepository _saleRepository;
  final ClientRepository _clientRepository;
  final PaymentRepository _paymentRepository;
  final int _saleId;

  Sale? _sale;
  String? _clientName;
  List<Payment> _payments = <Payment>[];

  /// Vente affichée.
  Sale? get sale => _sale;

  /// Nom du client acheteur.
  String? get clientName => _clientName;

  /// Paiements imputés sur cette vente.
  List<Payment> get payments => _payments;

  Future<void> load() async {
    await guard(() async {
      setLoading();

      _sale = await _saleRepository.getById(_saleId);
      if (_sale == null) {
        setError('Cette vente est introuvable.');
        return;
      }

      final int? clientId = _sale!.clientId;
      if (clientId != null) {
        final client = await _clientRepository.getById(clientId);
        _clientName = client?.name;
      }
      _payments = await _paymentRepository.getBySale(_saleId);

      setSuccess();
    });
  }
}

class _SaleDetailView extends StatefulWidget {
  const _SaleDetailView();

  @override
  State<_SaleDetailView> createState() => _SaleDetailViewState();
}

class _SaleDetailViewState extends State<_SaleDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<_SaleDetailViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _SaleDetailViewModel viewModel = context
        .watch<_SaleDetailViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la vente')),
      body: SafeArea(child: _buildBody(context, viewModel)),
    );
  }

  Widget _buildBody(BuildContext context, _SaleDetailViewModel viewModel) {
    switch (viewModel.status) {
      case ViewStatus.loading:
        return const LoadingView(message: 'Chargement...');
      case ViewStatus.error:
        return ErrorView(
          message: viewModel.errorMessage ?? 'Impossible de charger la vente.',
          onRetry: viewModel.load,
        );
      case ViewStatus.empty:
      case ViewStatus.success:
        final Sale? sale = viewModel.sale;
        if (sale == null) return const SizedBox.shrink();
        return _buildContent(context, sale, viewModel);
    }
  }

  Widget _buildContent(
    BuildContext context,
    Sale sale,
    _SaleDetailViewModel viewModel,
  ) {
    final bool isPaid = sale.paymentStatus == PaymentStatus.paid;
    final Color statusColor = isPaid
        ? AppColors.success
        : AppColors.error;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          viewModel.clientName ?? 'Client comptoir',
                          style: AppTextStyles.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          Formatters.dateTime(
                            sale.createdAt ?? DateTime.now(),
                          ),
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle : Icons.error_outline,
                        size: 18,
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
              const SizedBox(height: AppDimensions.spacingLg),
              _Line(
                label: 'Quantité',
                value: Formatters.quantity(sale.quantity),
              ),
              _Line(
                label: 'Prix par sac',
                value: Formatters.amount(sale.unitPrice),
              ),
              const Divider(height: AppDimensions.spacingLg),
              _Line(
                label: 'Total',
                value: Formatters.amount(sale.totalAmount),
                isBold: true,
              ),
              _Line(
                label: 'Payé',
                value: Formatters.amount(sale.paidAmount),
                valueColor: AppColors.success,
              ),
              _Line(
                label: 'Reste dû',
                value: Formatters.amount(sale.creditAmount),
                valueColor: sale.creditAmount > 0
                    ? AppColors.warning
                    : AppColors.success,
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const SectionTitle(title: 'Règlements de cette vente'),
        const SizedBox(height: AppDimensions.spacingMd),
        if (viewModel.payments.isEmpty)
          const AppCard(
            child: EmptyState(
              icon: Icons.payments_outlined,
              title: 'Aucun règlement',
              message: 'Aucun paiement n\'a encore été enregistré.',
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (final Payment payment in viewModel.payments)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacingSm,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 18,
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
              ],
            ),
          ),
        const SizedBox(height: AppDimensions.spacingLg),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.small),
          AmountText(
            amount: value,
            style: isBold ? AppTextStyles.bodyBold : AppTextStyles.body,
            color: valueColor ?? context.appPalette.onSurface,
          ),
        ],
      ),
    );
  }
}