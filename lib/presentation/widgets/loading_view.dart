import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

/// Vue de chargement centrée, avec message optionnel.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  /// Message affiché sous le spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                message!,
                style: AppTextStyles.small,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}