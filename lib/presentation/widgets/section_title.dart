import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

/// Titre de section avec sous-titre optionnel.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.subtitle});

  /// Titre principal de la section.
  final String title;

  /// Précision affichée sous le titre.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.h3),
        if (subtitle != null) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          Text(subtitle!, style: AppTextStyles.small),
        ],
      ],
    );
  }
}