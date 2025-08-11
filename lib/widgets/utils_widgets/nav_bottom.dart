import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/provider/screen_nav_provider.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';

class NavBottom extends StatelessWidget {
  final List<NavDestination> destinations;
  final List<String> routeNames;
  final int currentPageIndex;

  /// 底部导航栏 NavigationBar(MD3)/BottomNavigationBar(MD2)
  const NavBottom({
    super.key,
    required this.destinations,
    required this.routeNames,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).useMaterial3
        ? NavigationBar(
            onDestinationSelected: (int index) {
              if (index != currentPageIndex) {
                context
                    .read<ScreenNavProvider>()
                    .setCurrentPage(routeNames[index]);
              }
            },
            selectedIndex: currentPageIndex,
            destinations: <Widget>[
              ...destinations.map(
                (NavDestination destination) {
                  return NavigationDestination(
                    icon: destination.icon,
                    selectedIcon: destination.selectedIcon,
                    label: destination.label,
                  );
                },
              ),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          )
        : BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              ...destinations.map(
                (NavDestination destination) {
                  return BottomNavigationBarItem(
                    icon: destination.icon,
                    activeIcon: destination.selectedIcon,
                    label: destination.label,
                  );
                },
              ),
            ],
            currentIndex: currentPageIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              if (index != currentPageIndex) {
                context
                    .read<ScreenNavProvider>()
                    .setCurrentPage(routeNames[index]);
              }
            },
            showUnselectedLabels: false,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
          );
  }
}
