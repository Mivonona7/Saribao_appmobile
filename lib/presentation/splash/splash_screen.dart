import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/l10n/app_strings.dart';
import '../widgets/error_view.dart';
import '../widgets/app_logo.dart';
import 'splash_view_model.dart';

/// Écran d'accueil de l'application.
///
/// Reste affiché uniquement le temps de l'initialisation réelle, puis
/// remplace la pile par le dashboard. Aucun délai artificiel.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  /// Empêche une double navigation si le build est rejoué.
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SplashViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStatusChanged() {
    if (_hasNavigated || !mounted) return;

    final SplashStatus status = context.read<SplashViewModel>().status;

    switch (status) {
      case SplashStatus.ready:
        _hasNavigated = true;
        Navigator.of(
          context,
        ).pushReplacementNamed(AppRoutes.dashboard);
      case SplashStatus.failed:
        _hasNavigated = false;
      case SplashStatus.initializing:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashStatus status = context.select<SplashViewModel, SplashStatus>(
      (SplashViewModel vm) => vm.status,
    );

    if (status == SplashStatus.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleStatusChanged());
    }

    return Scaffold(
      backgroundColor: context.appPalette.surface,
      body: SafeArea(
        child: status == SplashStatus.failed
            ? _SplashError(message: context.read<SplashViewModel>().errorMessage)
: FadeTransition(
                opacity: _fadeAnimation,
                // Pas de `const` : les textes viennent du contexte, donc ils
                // sont résolus au moment de la construction.
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(size: 120, showBackground: false),
                      const SizedBox(height: AppDimensions.spacingLg),
                      Text(
                        context.t('about.appName'),
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        context.t('about.tagline'),
                        style: AppTextStyles.small,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingXxl),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      Text(
                        context.t('common.loading'),
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Affiche une erreur d'initialisation avec reprise possible.
class _SplashError extends StatelessWidget {
  const _SplashError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      message: message ?? 'Impossible de démarrer l\'application.',
      onRetry: () => context.read<SplashViewModel>().initialize(),
    );
  }
}