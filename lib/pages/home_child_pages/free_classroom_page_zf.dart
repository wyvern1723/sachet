import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_zf_child_pages/free_classroom_filter_page_zf.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_zf_child_pages/free_classroom_query_page_zf.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_zf_child_pages/free_classroom_today_and_tomorrow.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';

import 'package:provider/provider.dart';
import 'package:sachet/providers/settings_provider.dart';

const routeFilterScreen = 'filter';
const routeResultScreen = 'result';

class FreeClassroomPageZF extends StatelessWidget {
  /// 空闲教室(正方教务)
  const FreeClassroomPageZF({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FreeClassroomPageZFProvider(),
      child: FreeClassroomPageZFView(),
    );
  }
}

class FreeClassroomPageZFView extends StatefulWidget {
  const FreeClassroomPageZFView({super.key});

  @override
  State<FreeClassroomPageZFView> createState() =>
      _FreeClassroomPageZFViewState();
}

class _FreeClassroomPageZFViewState extends State<FreeClassroomPageZFView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onFiltering() {
    _navigatorKey.currentState!.pop();
  }

  void _onShowResult() {
    _navigatorKey.currentState!.pushNamed(routeResultScreen);
  }

  @override
  Widget build(BuildContext context) {
    /// 是否使用以前的 今日/明日 样式
    bool useLegacyStyle = context.select<SettingsProvider, bool>(
        (settingsProvider) => settingsProvider.isFreeClassroomUseLegacyStyle);
    if (useLegacyStyle) {
      return FreeClassroomTodayAndTomorrow();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('空闲教室'),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.swap_horiz),
              onPressed: () {
                context
                    .read<SettingsProvider>()
                    .setIsFreeClassroomUseLegacyStyle(true);
              },
              label: Text('旧版样式'),
            ),
          ],
        ),
        body: NavigatorPopHandler(
          onPop: () {
            // 当返回事件发生时，尝试在嵌套的 Navigator 中 pop
            // 如果嵌套的 Navigator 已经没有可以 pop 的页面，它将什么也不做
            // 这种情况下，外部的 Navigator 将会处理返回事件
            _navigatorKey.currentState?.pop();
          },
          child: Navigator(
            key: _navigatorKey,
            initialRoute: routeFilterScreen,
            onGenerateRoute: _onGenerateRoute,
          ),
        ),
      );
    }
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      routeFilterScreen =>
        FreeClassroomFilterScreenZF(onShowResult: _onShowResult),
      routeResultScreen => FreeClassroomQueryPageZF(onFiltering: _onFiltering),
      _ => throw StateError('Unexpected route name: ${settings.name}!'),
    };

    return CupertinoPageRoute(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }
}
