import 'package:flutter/material.dart';
import 'package:sachet/models/nav_destination.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class NavDrawerMD2 extends StatefulWidget {
  const NavDrawerMD2({
    super.key,
  });

  @override
  State<NavDrawerMD2> createState() => _NavDrawerMD2State();
}

class _NavDrawerMD2State extends State<NavDrawerMD2> {
  // void _onItemTapped(int itemIndex) {

  // 是否在 Drawer 显示编辑账号
  bool showUserDetails = false;

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

  // 正常的 DrawerList
  Widget _buildDrawerList() {
    return Column(
      children: [
        ...navDrawerDestinations.map(
          (NavDestination destination) {
            return ListTile(
              title: Text(destination.label),
              leading: destination.selectedIcon,
              selected: ScreenNavProvider.currentPage == destination.routeName,
              selectedTileColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              onTap: () async {
                await _handleScreenChanged(destination.routeName);
              },
            );
          },
        ),
      ]..insert(
          2,
          Divider(),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          MyUserAccountDrawerHeader(),
          _buildDrawerList(),
        ],
      ),
    );
  }
}
