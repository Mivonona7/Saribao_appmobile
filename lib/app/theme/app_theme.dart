import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

/// `ThemeData` de l'application.
///
/// Les vues ne construisent jamais de `TextStyle` ni de couleurs en dur :
/// elles passent par `AppTextStyles`, `AppColors`, `AppPalette` et
/// `AppDimensions`. Seul ce fichier (et [AppColors] / [AppPalette]) définit
/// les valeurs visuelles.
abstract final class AppTheme {
  /// Thème clair.
  static final ThemeData light = _build(
    brightness: Brightness.light,
    palette: AppPalette.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primary,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.dark,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    ),
  );

  /// Thème sombre.
  ///
  /// La barre d'application reste violette dans les deux modes : c'est la
  /// signature visuelle de SARIBAO, et la changer rendrait la navigation
  /// illisible au-dessus des cartes sombres.
  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    palette: AppPalette.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: Color(0xFF322C55),
      onPrimaryContainer: Color(0xFFDDD6FE),
      secondary: AppColors.primary,
      onSecondary: AppColors.white,
      surface: Color(0xFF1E1E27),
      onSurface: Color(0xFFF3F4F6),
      error: AppColors.error,
      onError: AppColors.white,
      outline: Color(0xFF33333F),
      outlineVariant: Color(0xFF33333F),
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppPalette palette,
    required ColorScheme colorScheme,
  }) {
    const textTheme = TextTheme(
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      titleLarge: AppTextStyles.h3,
      titleMedium: AppTextStyles.bodyBold,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.small,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.caption,
      labelSmall: AppTextStyles.caption,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      extensions: <ThemeExtension<dynamic>>[palette],
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: const IconThemeData(color: AppColors.white, size: 24),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          side: BorderSide(color: palette.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingLg,
        ),
        hintStyle: AppTextStyles.small,
        labelStyle: AppTextStyles.small,
        floatingLabelStyle: AppTextStyles.small,
        helperStyle: AppTextStyles.caption,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: palette.border,
          disabledForegroundColor: palette.secondaryText,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          textStyle: AppTextStyles.button,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyBold,
          minimumSize: const Size(0, AppDimensions.minTouchTarget),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.onSurface,
        contentTextStyle: AppTextStyles.body.copyWith(color: palette.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: palette.secondaryText,
        selectedLabelStyle: AppTextStyles.captionBold.copyWith(
          color: AppColors.primary,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          color: palette.secondaryText,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: palette.border,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.secondaryText,
        textColor: palette.onSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primarySoft,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          AppTextStyles.caption,
        ),
      ),
    );
  }
}