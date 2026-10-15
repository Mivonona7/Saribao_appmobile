import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/models/app_settings.dart';
import '../widgets/app_card.dart';
import 'settings_view_model.dart';

/// Écran des paramètres : apparence et informations sur l'application.
///
/// Le réglage d'apparence s'applique immédiatement, sans validation.
///
/// Le `SettingsViewModel` vient de `SaribaoApp` : c'est lui qui construit
/// `MaterialApp`. Un ViewModel local ici ne changerait que cet écran, et le
/// thème resterait clair ailleurs.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsViewModel viewModel = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('settings.title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spacingLg,
            AppDimensions.screenPadding,
            AppDimensions.spacingXl,
          ),
          children: [
            _AppearanceSection(viewModel: viewModel),
            const SizedBox(height: AppDimensions.spacingLg),
            const _AboutEntry(),
            const SizedBox(height: AppDimensions.spacingLg),
            const _OfflineNotice(),
          ],
        ),
      ),
    );
  }
}

/// Sélecteur d'apparence : clair, sombre ou automatique.
class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final AppThemeModeSetting selected = viewModel.settings.themeMode;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.palette_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.t('settings.appearance'),
                      style: AppTextStyles.bodyBold,
                    ),
                    Text(
                      context.t('settings.appearanceSubtitle'),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          _SegmentedRow<AppThemeModeSetting>(
            values: AppThemeModeSetting.values,
            selected: selected,
            // Les libellés et les icônes suivent la langue active, donc le
            // contenu du sélecteur doit être reconstruit à chaque changement.
            labelOf: (AppThemeModeSetting setting) =>
                context.t(_themeKey(setting)),
            iconOf: _themeIcon,
            onChanged: viewModel.setThemeMode,
          ),
        ],
      ),
    );
  }

  static String _themeKey(AppThemeModeSetting setting) {
    switch (setting) {
      case AppThemeModeSetting.system:
        return 'settings.themeSystem';
      case AppThemeModeSetting.light:
        return 'settings.themeLight';
      case AppThemeModeSetting.dark:
        return 'settings.themeDark';
    }
  }

  static IconData _themeIcon(AppThemeModeSetting setting) {
    switch (setting) {
      case AppThemeModeSetting.system:
        return Icons.brightness_auto_outlined;
      case AppThemeModeSetting.light:
        return Icons.light_mode_outlined;
      case AppThemeModeSetting.dark:
        return Icons.dark_mode_outlined;
    }
  }
}

/// Rangée de boutons exclusifs, avec icône et libellé.
///
/// `SegmentedButton` de Material n'accepte qu'un libellé par segment et
/// n'offre pas d'icône : la rangée est construite ici pour garder le même
/// gabarit sur les deux réglages.
class _SegmentedRow<T> extends StatelessWidget {
  const _SegmentedRow({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.iconOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final IconData Function(T value) iconOf;
  final Future<void> Function(T value) onChanged;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingXs),
      child: Row(
        children: [
          for (final T value in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXs,
                ),
                child: _Segment<T>(
                  label: labelOf(value),
                  icon: iconOf(value),
                  isSelected: value == selected,
                  onTap: () => onChanged(value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Material(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall - 2),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingSm,
            horizontal: AppDimensions.spacingXs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.white : palette.secondaryText,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.captionBold.copyWith(
                  color: isSelected ? AppColors.white : palette.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accès à l'écran « À propos ».
class _AboutEntry extends StatelessWidget {
  const _AboutEntry();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t('settings.about'),
                  style: AppTextStyles.bodyBold,
                ),
                Text(
                  context.t('settings.aboutSubtitle'),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: context.appPalette.secondaryText,
          ),
        ],
      ),
    );
  }
}

/// Rappel que l'application ne dépend d'aucun service externe.
class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t('settings.offline'),
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  context.t('settings.offlineMessage'),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}