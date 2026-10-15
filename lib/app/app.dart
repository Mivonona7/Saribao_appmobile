import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/di/app_dependencies.dart';
import '../core/l10n/app_strings.dart';
import '../presentation/dashboard/dashboard_view_model.dart';
import '../presentation/settings/settings_view_model.dart';
import '../presentation/splash/splash_view_model.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

/// Racine de l'application SARIBAO.
///
/// L'injection est faite ici, une seule fois : les repositories sont créés
/// par [AppDependencies] puis les ViewModels reçoivent exactement les
/// repositories dont ils ont besoin. Aucune vue n'accède à SQLite.
///
/// [SettingsViewModel] est volontairement le seul à piloter `MaterialApp` :
/// le mode d'apparence et la locale y sont lus, donc un changement dans les
/// réglages reconstruit toute l'application sans qu'aucun écran ne le sache.
class SaribaoApp extends StatelessWidget {
  const SaribaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: AppDependencies.create()),
        ChangeNotifierProvider<SplashViewModel>(
          create: (BuildContext context) => SplashViewModel(),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (BuildContext context) {
            final AppDependencies dependencies = context
                .read<AppDependencies>();
            final SettingsViewModel viewModel = SettingsViewModel(
              settingsRepository: dependencies.settingsRepository,
            );
            // Chargé sans attendre : `AppBootstrap` ouvre déjà la base, et les
            // valeurs par défaut s'appliquent si la lecture n'a pas fini.
            unawaited(viewModel.load());
            return viewModel;
          },
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (BuildContext context) {
            final AppDependencies dependencies = context
                .read<AppDependencies>();
            return DashboardViewModel(
              stockRepository: dependencies.stockRepository,
              saleRepository: dependencies.saleRepository,
              paymentRepository: dependencies.paymentRepository,
              clientRepository: dependencies.clientRepository,
            );
          },
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (
          BuildContext context,
          SettingsViewModel settings,
          Widget? child,
        ) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<Object?>>[
              AppStrings.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}