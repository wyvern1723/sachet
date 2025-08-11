import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/class_page.dart';
import 'package:sachet/pages/home_page.dart';
import 'package:sachet/pages/profile_page.dart';
import 'package:sachet/pages/settings_page.dart';
import 'package:sachet/provider/screen_nav_provider.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';
import 'package:sachet/widgets/utils_widgets/nav_bottom.dart';
import 'package:sachet/widgets/utils_widgets/nav_side.dart';

const List<String> _routeNames = ['/class', '/home', '/profile'];

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
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      // 是否宽屏。
      // 为什么还要判断主题是否启用了 MD3 呢，
      // 因为如果是 MD2 风格，AppBar 背景色为主题色,而侧边导航栏 NavigationRail 背景色是白色，看起来不协调。
      // 启用 MD3 时，两者背景色都是白色。
      // TODO: 优化 MaterialDesign2 时的宽屏模式（响应式设计）
      final bool isWideScreenMode = (constraints.maxWidth > 600 &&
          Theme.of(context).useMaterial3 == true);
      return Scaffold(
        body: Row(
          children: [
            if (isWideScreenMode)
              SafeArea(
                child: NavSide(
                  destinations: _destinations,
                  routeNames: _routeNames,
                  currentPageIndex: currentPageIndex,
                ),
              ),
            Expanded(
              child: [ClassPage(), HomePage(), ProfilePage()][currentPageIndex],
            ),
          ],
        ),
        bottomNavigationBar: !isWideScreenMode
            ? NavBottom(
                destinations: _destinations,
                routeNames: _routeNames,
                currentPageIndex: currentPageIndex,
              )
            : null,
      );
    });
  }
}
