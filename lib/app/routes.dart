import 'package:flutter/material.dart';

import '../presentation/arrivals/arrival_form_screen.dart';
import '../presentation/arrivals/arrivals_screen.dart';
import '../presentation/clients/client_detail_screen.dart';
import '../presentation/clients/client_form_screen.dart';
import '../presentation/dashboard/main_shell.dart';
import '../presentation/reports/reports_screen.dart';
import '../presentation/sales/sale_detail_screen.dart';
import '../presentation/sales/sale_form_screen.dart';
import '../presentation/settings/about_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/splash/splash_screen.dart';

/// Noms de routes et fabrique de routes de l'application.
///
/// Les onglets passent tous par [MainShell] avec un index : une seule
/// coquille, donc l'état de l'onglet survit aux allers-retours.
abstract final class AppRoutes {
  /// Écran affiché au lancement.
  static const String splash = '/';

  /// Coquille principale avec la barre d'onglets.
  static const String dashboard = '/dashboard';

  /// Onglet Stock.
  static const String stock = '/stock';

  /// Onglet Ventes.
  static const String sales = '/sales';

  /// Onglet Clients.
  static const String clients = '/clients';

  /// Formulaire de nouvelle vente.
  static const String saleForm = '/sale/new';

  /// Détail d'une vente (argument : identifiant).
  static const String saleDetail = '/sale/detail';

  /// Formulaire de nouvel arrivage.
  static const String arrivalForm = '/arrival/new';

  /// Historique des arrivages.
  static const String arrivals = '/arrivals';

  /// Formulaire de nouveau client.
  static const String clientForm = '/client/new';

  /// Profil d'un client (argument : identifiant).
  static const String clientDetail = '/client/detail';

  /// Rapports et statistiques.
  static const String reports = '/reports';

  /// Préférences : apparence et langue.
  static const String settings = '/settings';

  /// À propos de l'application et du développeur.
  static const String about = '/about';

  /// Fabrique les routes à partir de leur nom.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen(), settings);
      case dashboard:
        return _page(const MainShell(), settings);
      case stock:
        return _page(const MainShell(initialIndex: 1), settings);
      case sales:
        return _page(const MainShell(initialIndex: 2), settings);
      case clients:
        return _page(const MainShell(initialIndex: 3), settings);
      case saleForm:
        return _page(const SaleFormScreen(), settings);
      case saleDetail:
        return _page(
          SaleDetailScreen(saleId: settings.arguments! as int),
          settings,
        );
      case arrivalForm:
        return _page(const ArrivalFormScreen(), settings);
      case arrivals:
        return _page(
          const ArrivalsViewModelProvider(child: ArrivalsScreen()),
          settings,
        );
      case clientForm:
        return _page(const ClientFormScreen(), settings);
      case clientDetail:
        return _page(
          ClientDetailScreen(clientId: settings.arguments! as int),
          settings,
        );
      case reports:
        return _page(const ReportsScreen(), settings);
      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);
      case about:
        return _page(const AboutScreen(), settings);
      default:
        return _page(const MainShell(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => child,
      settings: settings,
    );
  }
}