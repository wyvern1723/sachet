import 'package:flutter/material.dart' hide NavigationDrawerDestination;
import 'package:sachet/models/nav_destination.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
import 'package:sachet/widgets/modified_widgets/my_navigation_drawer.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class NavDrawerMD3 extends StatefulWidget {
  const NavDrawerMD3({super.key});

  @override
  State<NavDrawerMD3> createState() => _NavDrawerMD3State();
}

class _NavDrawerMD3State extends State<NavDrawerMD3> {
  final List _routeNames = ['/class', '/home', '/settings', '/about'];

  Future _handleScreenChanged(String routeName) async {
    if (ScreenNavProvider.currentPage == routeName) {
      Navigator.pop(context);
      return;
    }
    if (routeName == '/class' || routeName == '/home') {
      context.read<ScreenNavProvider>().setCurrentPage(routeName);

      Navigator.pop(context);
      await Future.delayed(Duration(milliseconds: 200));
      Navigator.of(context).pushReplacementNamed(routeName);
    } else {
      Navigator.pop(context);
      await Future.delayed(Duration(milliseconds: 200));
      Navigator.of(context).pushNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyNavigationDrawer(
      onDestinationSelected: (index) {
        _handleScreenChanged(_routeNames[index]);
      },
      selectedIndex: _routeNames.indexOf(ScreenNavProvider.currentPage),
      children: <Widget>[
        MyUserAccountDrawerHeader(),
        ...navDrawerDestinations.map(
          (NavDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
      ]..insert(
          3,
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 10, 28, 10),
            child: Divider(),
          ),
        ),
    );
  }
}
