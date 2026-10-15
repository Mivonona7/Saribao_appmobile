import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saribao/app/theme/app_colors.dart';
import 'package:saribao/app/theme/app_dimensions.dart';
import 'package:saribao/app/theme/app_text_styles.dart';
import 'package:saribao/app/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('expose exactement la palette définie pour SARIBAO', () {
      expect(AppColors.primary, const Color(0xFF6C5CE7));
      expect(AppColors.white, const Color(0xFFFFFFFF));
      expect(AppColors.dark, const Color(0xFF1F2937));
      expect(AppColors.background, const Color(0xFFF5F6FA));
      expect(AppColors.secondaryText, const Color(0xFF6B7280));
      expect(AppColors.border, const Color(0xFFE5E7EB));
      expect(AppColors.success, const Color(0xFF22C55E));
      expect(AppColors.warning, const Color(0xFFF59E0B));
      expect(AppColors.error, const Color(0xFFEF4444));
    });
  });

  group('AppTextStyles', () {
    test('respectent la hiérarchie de tailles', () {
      expect(AppTextStyles.h1.fontSize, 24);
      expect(AppTextStyles.h2.fontSize, 20);
      expect(AppTextStyles.h3.fontSize, 18);
      expect(AppTextStyles.body.fontSize, 16);
      expect(AppTextStyles.small.fontSize, 14);
      expect(AppTextStyles.caption.fontSize, 12);
    });

    test('utilisent les graisses attendues', () {
      expect(AppTextStyles.h1.fontWeight, FontWeight.w700);
      expect(AppTextStyles.h2.fontWeight, FontWeight.w700);
      expect(AppTextStyles.h3.fontWeight, FontWeight.w600);
      expect(AppTextStyles.body.fontWeight, FontWeight.w400);
    });

    test('demandent la famille Inter', () {
      expect(AppTextStyles.fontFamily, 'Inter');
      expect(AppTextStyles.body.fontFamily, 'Inter');
    });
  });

  group('AppDimensions', () {
    test('respectent les contraintes de design', () {
      expect(AppDimensions.screenPadding, 16);
      expect(AppDimensions.buttonHeight, 52);
      expect(AppDimensions.radius, 16);
      expect(AppDimensions.radiusSmall, 12);
      expect(AppDimensions.minTouchTarget, greaterThanOrEqualTo(44));
    });
  });

  group('AppTheme', () {
    test('applique la couleur principale et le fond d\'écran', () {
      final ThemeData theme = AppTheme.light;

      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.appBarTheme.backgroundColor, AppColors.primary);
    });

    test('configure la barre d\'onglets avec les couleurs active/inactive', () {
      final BottomNavigationBarThemeData nav = AppTheme.light
          .bottomNavigationBarTheme;

      expect(nav.selectedItemColor, AppColors.primary);
      expect(nav.unselectedItemColor, AppColors.secondaryText);
    });

    test('garantit une zone tactile d\'au moins 48 px pour les boutons', () {
      final Size? size =
          AppTheme.light.filledButtonTheme.style!.minimumSize!.resolve(
            <WidgetState>{},
          );

      expect(size!.height, AppDimensions.buttonHeight);
      expect(size.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
    });
  });
}