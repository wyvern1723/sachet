import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/provider/screen_nav_provider.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';

class NavSide extends StatelessWidget {
  final List<NavDestination> destinations;
  final List<String> routeNames;
  final int currentPageIndex;

  /// 侧边导航栏 (NavigationRail)
  const NavSide({
    super.key,
    required this.destinations,
    required this.routeNames,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentPageIndex,
      onDestinationSelected: (int index) {
        if (index != currentPageIndex) {
          context.read<ScreenNavProvider>().setCurrentPage(routeNames[index]);
        }
      },
      labelType: NavigationRailLabelType.all,
      destinations: <NavigationRailDestination>[
        ...destinations.map(
          (NavDestination destination) {
            return NavigationRailDestination(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              label: Text(destination.label),
            );
          },
        ),
      ],
    );
  }
}
