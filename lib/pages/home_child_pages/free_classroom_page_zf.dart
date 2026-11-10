import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sachet/pages/home_child_pages/free_classroom_zf_child_pages/free_classroom_filter_page_zf.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_zf_child_pages/free_classroom_query_page_zf.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_zf_child_pages/free_classroom_today_and_tomorrow.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_widgets/free_classroom_actions_bottom_sheet.dart';

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

  /// 当前是否处于查询结果页（用于隐藏“更多操作”按钮）
  bool _isResultRouteShowing = false;

  void _onFiltering() {
    setState(() => _isResultRouteShowing = false);
    _navigatorKey.currentState!.pop();
  }

  void _onShowResult() {
    setState(() => _isResultRouteShowing = true);
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
          elevation: !Theme.of(context).useMaterial3 ? 0 : null,
          title: const Text('空闲教室'),
          actions: [
            TextButton.icon(
              style: Theme.of(context).useMaterial3
                  ? null
                  : TextButton.styleFrom(foregroundColor: Colors.white),
              icon: Icon(Icons.swap_horiz),
              onPressed: () {
                context
                    .read<SettingsProvider>()
                    .setIsFreeClassroomUseLegacyStyle(true);
              },
              label: Text('旧版样式'),
            ),
            if (!_isResultRouteShowing)
              IconButton(
                icon: Icon(Icons.more_vert),
                tooltip: '更多操作',
                color: Theme.of(context).useMaterial3
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                onPressed: () async {
                  await FreeClassroomActionsBottomSheet.show(context);
                },
              ),
          ],
        ),
        body: NavigatorPopHandler(
          onPop: () {
            // 当返回事件发生时，尝试在嵌套的 Navigator 中 pop
            // 如果嵌套的 Navigator 已经没有可以 pop 的页面，它将什么也不做
            // 这种情况下，外部的 Navigator 将会处理返回事件
            if (_navigatorKey.currentState?.canPop() ?? false) {
              setState(() => _isResultRouteShowing = false);
              _navigatorKey.currentState!.pop();
            }
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
