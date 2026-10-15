import '../constants/app_constants.dart';

/// Formateurs d'affichage. Aucune dépendance externe : tout est local
/// et fonctionne 100% offline.
abstract final class Formatters {
  /// Séparateur de milliers (espace).
  static const String _groupSeparator = ' ';

  /// Formate un montant en ariary.
  ///
  /// ```dart
  /// Formatters.amount(75000); // '75 000 Ar'
  /// ```
  static String amount(int value) {
    final String digits = _group(value.abs());
    final String sign = value < 0 ? '-' : '';
    return '$sign$digits ${AppConstants.currencySuffix}';
  }

  /// Formate une quantité et son unité.
  ///
  /// ```dart
  /// Formatters.quantity(1);  // '1 sac'
  /// Formatters.quantity(12); // '12 sacs'
  /// ```
  static String quantity(int value) {
    final int magnitude = value.abs();
    final String unit = magnitude == 1
        ? AppConstants.unitLabel
        : AppConstants.pluralUnitLabel;
    return '${_group(magnitude)} $unit';
  }

  /// Formate une date au format `jj/mm/aaaa`.
  static String date(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  /// Formate une date et l'heure au format `jj/mm/aaaa hh:mm`.
  static String dateTime(DateTime value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '${date(value)} $hour:$minute';
  }

  /// Insère des séparateurs de milliers tous les trois chiffres.
  static String _group(int value) {
    final String raw = value.toString();
    if (raw.length <= 3) return raw;

    final StringBuffer buffer = StringBuffer();
    final int leading = raw.length % 3;
    if (leading > 0) buffer.write(raw.substring(0, leading));

    for (int i = leading; i < raw.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(_groupSeparator);
      buffer.write(raw.substring(i, i + 3));
    }
    return buffer.toString();
  }
}