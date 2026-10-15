import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/l10n/app_strings.dart';
import '../widgets/app_card.dart';
import '../widgets/app_logo.dart';
import '../widgets/section_title.dart';

/// Écran « À propos » : présentation de l'application et de son développeur.
///
/// Aucune information n'est inventée : seuls le nom du développeur, la version
/// réellement compilée et les caractéristiques techniques constantes sont
/// affichés.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Version lue dans `pubspec.yaml` au moment de la compilation.
  static const String version = '1.0.0';

  /// Numéro de build, incrémenté à chaque publication.
  static const String buildNumber = '1';

  /// Chemin de la photo du développeur, déclarée dans `pubspec.yaml`.
  static const String developerPhotoAsset = 'assets/dev/andry.png';

  /// Nom du développeur, tel qu'il doit être crédité.
  static const String developerName = 'Andry RAMANANTSOA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('about.title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spacingLg,
            AppDimensions.screenPadding,
            AppDimensions.spacingXl,
          ),
          children: [
            const _AppHeader(),
            const SizedBox(height: AppDimensions.spacingXl),
            const _DeveloperCard(),
            const SizedBox(height: AppDimensions.spacingLg),
            _TechnicalCard(),
            const SizedBox(height: AppDimensions.spacingLg),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

/// Logo, nom et tagline de l'application.
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(size: 96),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          context.t('about.appName'),
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          context.t('about.tagline'),
          style: AppTextStyles.small,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Carte du développeur : photo, nom et rôle.
class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('about.developer'),
            style: AppTextStyles.captionBold.copyWith(
              color: palette.secondaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DeveloperAvatar(),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // Le nom reste en majuscules quelle que soit la langue :
                      // c'est une signature, pas un texte traduisible.
                      AboutScreen.developerName,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      context.t('about.developerRole'),
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Photo du développeur, en cercle, avec repli sur ses initiales.
///
/// La photo est un asset embarqué : elle ne peut pas échouer sur le réseau.
/// Seule une image corrompue atteindrait le repli.
class _DeveloperAvatar extends StatelessWidget {
  const _DeveloperAvatar();

  @override
  Widget build(BuildContext context) {
    const double diameter = 84;
    final AppPalette palette = context.appPalette;

    return Container(
      width: diameter,
      height: diameter,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Image.asset(
        AboutScreen.developerPhotoAsset,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        semanticLabel: context.t('about.photoAlt'),
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return Center(
            child: Text(
              _initials(AboutScreen.developerName),
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }

  /// Initiales du nom, utilisées uniquement si la photo ne se charge pas.
  static String _initials(String name) {
    final List<String> parts = name
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

/// Version, plateforme et choix techniques.
class _TechnicalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: context.t('nav.about')),
          const SizedBox(height: AppDimensions.spacingMd),
          _InfoRow(
            icon: Icons.numbers_outlined,
            label: context.t('about.version'),
            value: '${AboutScreen.version} (${AboutScreen.buildNumber})',
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const _InfoRow(
            icon: Icons.phone_android_outlined,
            labelKey: 'about.platform',
            value: 'Android',
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _InfoRow(
            icon: Icons.offline_bolt_outlined,
            labelKey: 'settings.offline',
            value: context.t('about.builtWith'),
          ),
        ],
      ),
    );
  }
}

/// Ligne « icône + libellé + valeur » de la fiche technique.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.value,
    this.label,
    this.labelKey,
  }) : assert(label != null || labelKey != null);

  final IconData icon;
  final String? label;
  final String? labelKey;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final String resolvedLabel = label ?? context.t(labelKey!);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resolvedLabel,
                style: AppTextStyles.captionBold.copyWith(
                  color: palette.secondaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(value, style: AppTextStyles.small),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mention finale : droits et usage.
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Column(
      children: [
        Text(
          context.t('about.rights'),
          style: AppTextStyles.caption.copyWith(color: palette.secondaryText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          context.t('about.licence'),
          style: AppTextStyles.caption.copyWith(color: palette.secondaryText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}