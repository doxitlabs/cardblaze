import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/providers/deck_providers.dart';

class ScaffoldWithNav extends ConsumerWidget {
  const ScaffoldWithNav({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexForPath(location);

    final tabs = [
      _TabItem(label: l.nav_decks,    icon: Icons.grid_view_outlined,    activeIcon: Icons.grid_view,       path: '/'),
      _TabItem(label: l.nav_generate, icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome,    path: '/generate'),
      _TabItem(label: l.nav_stats,    icon: Icons.bar_chart_outlined,    activeIcon: Icons.bar_chart,       path: '/stats'),
      _TabItem(label: l.nav_settings, icon: Icons.settings_outlined,     activeIcon: Icons.settings,        path: '/settings'),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(cardsRefreshProvider.notifier).state++;
          context.go(tabs[index].path);
        },
        destinations: tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
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
  const _TabItem({required this.label, required this.icon, required this.activeIcon, required this.path});
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
}
