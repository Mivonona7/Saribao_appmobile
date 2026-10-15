import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';

/// Affiche un montant en ariary de façon cohérente dans toute l'application.
///
/// La valeur est déjà formatée par l'appelant via `Formatters.amount`.
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.color,
    this.textAlign = TextAlign.left,
  });

  /// Montant déjà formaté, par exemple `'75 000 Ar'`.
  final String amount;

  /// Style forcé. Par défaut [AppTextStyles.bodyBold].
  final TextStyle? style;

  /// Couleur du texte. Par défaut, la couleur de texte du thème actif.
  final Color? color;

  /// Alignement du texte.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      amount,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (style ?? AppTextStyles.bodyBold).copyWith(
        color: color ?? context.appPalette.onSurface,
      ),
    );
  }
}