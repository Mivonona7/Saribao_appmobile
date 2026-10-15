import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../clients/clients_screen.dart';
import '../sales/sales_screen.dart';
import '../stock/stock_screen.dart';
import 'dashboard_screen.dart';

/// Coquille principale : 4 onglets, aucun onglet imbriqué dans une liste.
///
/// Chaque onglet est enveloppé dans le provider de son ViewModel : le
/// ViewModel vit exactement aussi longtemps que l'onglet.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  /// Onglet affiché au premier build.
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack conserve l'état de chaque onglet lors des allers-retours,
      // sans reconstruire les écrans à chaque changement.
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardScreen(),
          StockViewModelProvider(child: StockScreen()),
          SalesViewModelProvider(child: SalesScreen()),
          ClientsViewModelProvider(child: ClientsScreen()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: context.t('nav.home'),
            tooltip: context.t('nav.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2_rounded),
            label: context.t('nav.stock'),
            tooltip: context.t('nav.stock'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag_outlined),
            activeIcon: const Icon(Icons.shopping_bag_rounded),
            label: context.t('nav.sales'),
            tooltip: context.t('nav.sales'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline_rounded),
            activeIcon: const Icon(Icons.people_rounded),
            label: context.t('nav.clients'),
            tooltip: context.t('nav.clients'),
          ),
        ],
      ),
    );
  }
}