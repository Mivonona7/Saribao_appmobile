import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Vue d'erreur : message compréhensible et bouton « Réessayer ».
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Réessayer',
  });

  /// Message d'erreur affiché à l'utilisateur, en langage courant.
  final String message;

  /// Action de nouvelle tentative. `null` masque le bouton.
  final VoidCallback? onRetry;

  /// Libellé du bouton de reprise.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 34,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              SizedBox(
                width: 200,
                child: AppOutlinedButton(
                  label: retryLabel,
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}