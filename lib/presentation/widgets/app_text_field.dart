import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';

/// Champ de saisie stylé : libellé au-dessus, erreur affichée en dessous.
///
/// Le style vient du thème ; ce widget ajoute seulement les conventions
/// SARIBAO (suffixe d'unité, clavier numérique, capitalisation).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixText,
    this.focusNode,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
  });

  /// Libellé affiché au-dessus du champ.
  final String label;

  /// Contrôleur du texte.
  final TextEditingController? controller;

  /// Texte d'exemple.
  final String? hintText;

  /// Précision affichée sous le champ.
  final String? helperText;

  /// Message d'erreur. Remplace [helperText] quand non nul.
  final String? errorText;

  /// Type de clavier.
  final TextInputType? keyboardType;

  /// Action du bouton du clavier.
  final TextInputAction? textInputAction;

  /// Notifié à chaque frappe.
  final ValueChanged<String>? onChanged;

  /// Notifié à la validation du clavier.
  final ValueChanged<String>? onSubmitted;

  /// Longueur maximale acceptée.
  final int? maxLength;

  /// Focus automatique à l'ouverture.
  final bool autofocus;

  /// Icône à gauche du champ.
  final IconData? prefixIcon;

  /// Texte affiché à droite dans le champ (unité, devise).
  final String? suffixText;

  /// Nœud de focus, pour piloter le clavier.
  final FocusNode? focusNode;

  /// Capitalisation automatique.
  final TextCapitalization textCapitalization;

  /// Formateurs d'entrée (chiffres uniquement, etc.).
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.appPalette.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: errorText == null ? helperText : null,
            errorText: errorText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: AppDimensions.iconSize),
            suffixText: suffixText,
          ),
        ),
      ],
    );
  }
}

/// Saisie d'un montant en ariary : clavier numérique, chiffres seuls.
///
/// L'utilisateur ne saisit jamais le total : il saisit uniquement le prix
/// unitaire, le total est calculé par l'application.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  /// Libellé du champ.
  final String label;

  /// Contrôleur du montant.
  final TextEditingController controller;

  /// Notifié à chaque frappe.
  final ValueChanged<String>? onChanged;

  /// Message d'erreur.
  final String? errorText;

  /// Précision affichée sous le champ.
  final String? helperText;

  /// Nœud de focus.
  final FocusNode? focusNode;

  /// Action du bouton du clavier.
  final TextInputAction? textInputAction;

  /// Focus automatique.
  final bool autofocus;

  /// Convertit une saisie en entier, sans espace ni symbole.
  static int parse(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      onChanged: onChanged,
      errorText: errorText,
      helperText: helperText,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: textInputAction,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textCapitalization: TextCapitalization.none,
      suffixText: 'Ar',
      prefixIcon: Icons.payments_outlined,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
    );
  }
}

/// Saisie d'un nombre de sacs : entier positif, minimum 1.
class QuantityField extends StatelessWidget {
  const QuantityField({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.focusNode,
    this.label = 'Nombre de sacs',
  });

  /// Contrôleur de la quantité.
  final TextEditingController controller;

  /// Notifié à chaque frappe.
  final ValueChanged<String>? onChanged;

  /// Message d'erreur.
  final String? errorText;

  /// Nœud de focus.
  final FocusNode? focusNode;

  /// Libellé du champ.
  final String label;

  /// Convertit une saisie en entier borné à un minimum de 0.
  static int parse(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      onChanged: onChanged,
      errorText: errorText,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.none,
      suffixText: 'sacs',
      prefixIcon: Icons.inventory_2_outlined,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
    );
  }
}