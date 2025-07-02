import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/class_page.dart';
import 'package:sachet/pages/home_page.dart';
import 'package:sachet/pages/profile_page.dart';
import 'package:sachet/pages/settings_page.dart';
import 'package:sachet/provider/screen_nav_provider.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';

const List _routeNames = ['/class', '/home', '/profile'];

const List<NavDestination> _destinations = <NavDestination>[
  NavDestination(
      label: '课程表',
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      page: ClassPage(),
      routeName: '/class'),
  NavDestination(
      label: 'Home',
      // icon: Icon(Icons.category_outlined),
      // selectedIcon: Icon(Icons.category),
      icon: Icon(Icons.apps_outlined),
      selectedIcon: Icon(Icons.apps_outlined),
      page: HomePage(),
      routeName: '/home'),
  NavDestination(
      label: '我',
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person),
      page: SettingsPage(),
      routeName: '/profile'),
];

class WithNavigationBarView extends StatelessWidget {
  /// 使用 NavigationBar 时的 View, 几个一级页面作为 body, 底部 bottomNavigationBar 用于导航
  const WithNavigationBarView({super.key});

  @override
  Widget build(BuildContext context) {
    int currentPageIndex = _routeNames.indexOf(
        context.select<ScreenNavProvider, String>(
            (screenNavProvider) => ScreenNavProvider.currentPage));
    return Scaffold(
      body: [ClassPage(), HomePage(), ProfilePage()][currentPageIndex],
      bottomNavigationBar: Theme.of(context).useMaterial3
          ? NavigationBar(
              onDestinationSelected: (int index) {
                if (index != currentPageIndex) {
                  context
                      .read<ScreenNavProvider>()
                      .setCurrentPage(_routeNames[index]);
                }
              },
              selectedIndex: currentPageIndex,
              destinations: <Widget>[
                ..._destinations.map(
                  (NavDestination destination) {
                    return NavigationDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: destination.label,
                    );
                  },
                ),
              ],
            )
          : BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                ..._destinations.map(
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
                      .setCurrentPage(_routeNames[index]);
                }
              },
            ),
    );
  }
}
