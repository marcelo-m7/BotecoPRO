import 'package:flutter/material.dart';

enum NavigationTab {
  home,
  tables,
  products,
  recipes,
  production
}

class BottomNavigation extends StatelessWidget {
  final NavigationTab currentTab;
  final Function(NavigationTab) onTabSelected;

  const BottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTab.index,
      onTap: (index) => onTabSelected(NavigationTab.values[index]),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Theme.of(context).colorScheme.primary,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_bar_outlined),
          activeIcon: Icon(Icons.table_bar),
          label: 'Mesas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Produtos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Receitas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.production_quantity_limits_outlined),
          activeIcon: Icon(Icons.production_quantity_limits),
          label: 'Produção',
        ),
      ],
    );
  }
}