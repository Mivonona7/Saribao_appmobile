import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';
import '../viewmodels/base_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// ViewModel du formulaire client : validation et enregistrement.
class ClientFormViewModel extends BaseViewModel {
  ClientFormViewModel({
    required ClientRepository clientRepository,
    Client? client,
  })  : _clientRepository = clientRepository,
        _existing = client;

  final ClientRepository _clientRepository;
  final Client? _existing;

  String? _nameError;
  String? _phoneError;
  bool _isSaving = false;

  /// `true` si le formulaire modifie un client existant.
  bool get isEditing => _existing != null;

  /// Erreur du champ nom.
  String? get nameError => _nameError;

  /// Erreur du champ téléphone.
  String? get phoneError => _phoneError;

  /// `true` pendant l'enregistrement.
  bool get isSaving => _isSaving;

  /// Nom pré-rempli (modification).
  String get initialName => _existing?.name ?? '';

  /// Téléphone pré-rempli (modification).
  String get initialPhone => _existing?.phone ?? '';

  /// Adresse pré-remplie (modification).
  String get initialAddress => _existing?.address ?? '';

  /// Valide la saisie. Renvoie `true` si elle est acceptable.
  bool validate(String name, String phone) {
    _nameError = name.trim().isEmpty ? 'Le nom est obligatoire.' : null;
    _phoneError = (phone.trim().isNotEmpty && phone.trim().length < 6)
        ? 'Numéro de téléphone trop court.'
        : null;
    safeNotify();
    return _nameError == null && _phoneError == null;
  }

  /// Enregistre le client. Renvoie `true` si l'écriture a réussi.
  Future<bool> save(String name, String phone, String address) async {
    if (!validate(name, phone)) return false;

    _isSaving = true;
    safeNotify();

    try {
      final Client client = Client(
        id: _existing?.id,
        name: name.trim(),
        phone: phone.trim().isEmpty ? null : phone.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
        createdAt: _existing?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (_existing == null) {
        await _clientRepository.create(client);
      } else {
        await _clientRepository.update(client);
      }
      return true;
    } on AppException catch (error) {
      _nameError = error.message;
      return false;
    } catch (error) {
      _nameError = describeError(error);
      return false;
    } finally {
      _isSaving = false;
      safeNotify();
    }
  }
}

/// Formulaire de création ou de modification d'un client.
///
/// Le ViewModel est créé ici : il n'a de dépendance que le repository clients,
/// injecté par le conteneur global.
class ClientFormScreen extends StatelessWidget {
  const ClientFormScreen({super.key, this.client});

  /// Client à modifier. `null` pour une création.
  final Client? client;

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = context.read<AppDependencies>();

    return ChangeNotifierProvider<ClientFormViewModel>(
      create: (BuildContext context) => ClientFormViewModel(
        clientRepository: dependencies.clientRepository,
        client: client,
      ),
      child: _ClientFormView(),
    );
  }
}

class _ClientFormView extends StatefulWidget {
  const _ClientFormView();

  @override
  State<_ClientFormView> createState() => _ClientFormViewState();
}

class _ClientFormViewState extends State<_ClientFormView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;

    final ClientFormViewModel viewModel = context
        .read<ClientFormViewModel>();
    _nameController.text = viewModel.initialName;
    _phoneController.text = viewModel.initialPhone;
    _addressController.text = viewModel.initialAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ClientFormViewModel viewModel = context
        .read<ClientFormViewModel>();

    final String name = _nameController.text;
    final bool saved = await viewModel.save(
      name,
      _phoneController.text,
      _addressController.text,
    );

    if (!mounted) return;

    if (saved) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              viewModel.isEditing
                  ? 'Client modifié.'
                  : 'Client ${name.trim()} ajouté.',
            ),
          ),
        );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ClientFormViewModel viewModel = context
        .watch<ClientFormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.isEditing ? 'Modifier le client' : 'Nouveau client',
        ),
      ),
      body: SafeArea(
        // SingleChildScrollView : le clavier ne doit jamais masquer un champ.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Nom du client',
                controller: _nameController,
                hintText: 'Ex : Rakoto',
                autofocus: !viewModel.isEditing,
                prefixIcon: Icons.person_outline,
                errorText: viewModel.nameError,
                textInputAction: TextInputAction.next,
                onChanged: (_) => viewModel.validate(
                  _nameController.text,
                  _phoneController.text,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              AppTextField(
                label: 'Téléphone (facultatif)',
                controller: _phoneController,
                hintText: 'Ex : 034 12 345 67',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textCapitalization: TextCapitalization.none,
                errorText: viewModel.phoneError,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              AppTextField(
                label: 'Adresse (facultatif)',
                controller: _addressController,
                hintText: 'Ex : Antananarivo',
                prefixIcon: Icons.location_on_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              AppButton(
                label: viewModel.isEditing ? 'Enregistrer' : 'Ajouter',
                icon: Icons.check,
                isLoading: viewModel.isSaving,
                onPressed: _submit,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              AppOutlinedButton(
                label: 'Annuler',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}