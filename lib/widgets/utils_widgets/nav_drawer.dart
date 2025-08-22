import 'package:flutter/material.dart';
import 'package:sachet/models/nav_destination.dart';
import 'package:sachet/providers/qiangzhi_user_provider.dart';
import 'package:sachet/pages/about_page.dart';
import 'package:sachet/pages/class_page.dart';
import 'package:sachet/pages/home_page.dart';
import 'package:sachet/pages/settings_page.dart';
import 'package:sachet/pages/utilspages/qiangzhi_jwxt_login_page.dart';
import 'package:provider/provider.dart';

import 'nav_drawer_md2.dart';
import 'nav_drawer_md3.dart';

/// 导航 Drawer
Widget myNavDrawer = Builder(
  builder: (BuildContext context) => Theme.of(context).useMaterial3
      ? const NavDrawerMD3()
      : const NavDrawerMD2(),
);

/// Drawer Nav (抽屉导航）的 destinations
const List<NavDestination> navDrawerDestinations = <NavDestination>[
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
      label: '设置',
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      page: SettingsPage(),
      routeName: '/settings'),
  NavDestination(
      label: '关于',
      icon: Icon(Icons.info_outline),
      selectedIcon: Icon(Icons.info),
      page: AboutPage(),
      routeName: '/about'),
];

class MyUserAccountDrawerHeader extends StatelessWidget {
  const MyUserAccountDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    String name = context.select<QiangZhiUserProvider, String?>(
            (qiangzhiUserProvider) => qiangzhiUserProvider.user.name) ??
        '未登录';
    String studentID = context.select<QiangZhiUserProvider, String?>(
            (qiangzhiUserProvider) => qiangzhiUserProvider.user.studentID) ??
        '点击登录';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const QiangZhiJwxtLoginPage();
            },
          ),
        );
      },
      child: UserAccountsDrawerHeader(
        accountName: Text(
          name,
          style: TextStyle(color: Colors.white),
        ),
        accountEmail: Text(
          studentID,
          style: TextStyle(color: Colors.white),
        ),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
