import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _TabItem(label: 'Decks',    icon: Icons.grid_view_outlined,    activeIcon: Icons.grid_view,       path: '/'),
    _TabItem(label: 'Generate', icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome,    path: '/generate'),
    _TabItem(label: 'Stats',    icon: Icons.bar_chart_outlined,    activeIcon: Icons.bar_chart,       path: '/stats'),
    _TabItem(label: 'Settings', icon: Icons.settings_outlined,     activeIcon: Icons.settings,        path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexForPath(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) =>
            context.go(_tabs[index].path),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }

  static int _indexForPath(String path) {
    if (path.startsWith('/generate')) return 1;
    if (path.startsWith('/stats'))    return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
}
