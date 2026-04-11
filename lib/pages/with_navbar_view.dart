import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/nav_destination.dart';
import 'package:sachet/pages/class_page.dart';
import 'package:sachet/pages/home_page.dart';
import 'package:sachet/pages/profile_page.dart';
import 'package:sachet/pages/settings_page.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
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

class WithNavigationBarView extends StatefulWidget {
  /// 使用 NavigationBar 时的 View, 几个一级页面作为 body, 底部 bottomNavigationBar 用于导航
  const WithNavigationBarView({super.key});

  @override
  State<WithNavigationBarView> createState() => _WithNavigationBarViewState();
}

class _WithNavigationBarViewState extends State<WithNavigationBarView> {
  double? _scrollStartOffset;

  bool _onScrollNotification(ScrollNotification notification,
      bool isWideScreenMode, int currentPageIndex) {
    if (isWideScreenMode) {
      return false;
    }

    // 课程表水平滑动翻页时隐藏 NavBottom, 翻页结束显示 NavBottom
    if (notification.metrics.axis == Axis.horizontal) {
      if (currentPageIndex == 0) {
        if (notification is ScrollStartNotification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.read<ScreenNavProvider>().hideNavBottom();
          });
        } else if (notification is ScrollEndNotification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.read<ScreenNavProvider>().showNavBottom();
          });
        }
      }
      return false;
    }

    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        // 向下滚动立即隐藏 NavBottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.read<ScreenNavProvider>().hideNavBottom();
        });
        _scrollStartOffset = null;
      } else if (notification.direction == ScrollDirection.forward) {
        // 开始向上滚动，记录起始位置
        _scrollStartOffset = notification.metrics.pixels;

        // 如果已经滚动到顶部，立即显示 NavBottom
        final bool isAtTop = notification.metrics.pixels <= 0;
        if (isAtTop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.read<ScreenNavProvider>().showNavBottom();
          });
          _scrollStartOffset = null;
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      // 如果正在向上滚动
      if (notification.scrollDelta != null && notification.scrollDelta! < 0) {
        // 如果已经滚动到顶部，或者向上滚动距离超过 30px，则显示 NavBottom
        final bool isAtTop = notification.metrics.pixels <= 0;
        double distance = 0;
        if (_scrollStartOffset != null) {
          distance = _scrollStartOffset! - notification.metrics.pixels;
        }

        if (isAtTop || distance >= 30.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.read<ScreenNavProvider>().showNavBottom();
          });
          _scrollStartOffset = null;
        }
      }
    } else if (notification is ScrollEndNotification) {
      // 滚动结束时清理状态
      _scrollStartOffset = null;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final int currentPageIndex = _routeNames.indexOf(
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => _onScrollNotification(
                    notification, isWideScreenMode, currentPageIndex),
                child: [
                  ClassPage(),
                  HomePage(),
                  ProfilePage(),
                ][currentPageIndex],
              ),
            ),
          ],
        ),
        bottomNavigationBar: !isWideScreenMode
            ? Selector<ScreenNavProvider, bool>(
                selector: (_, provider) => provider.isNavBottomVisible,
                builder: (_, isNavBottomVisible, __) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: isNavBottomVisible ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: NavBottom(
                      destinations: _destinations,
                      routeNames: _routeNames,
                      currentPageIndex: currentPageIndex,
                    ),
                    builder: (context, value, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: value,
                          child: FractionalTranslation(
                            translation: Offset(0, 1 - value),
                            child: child,
                          ),
                        ),
                      );
                    },
                  );
                })
            : null,
      );
    });
  }
}
