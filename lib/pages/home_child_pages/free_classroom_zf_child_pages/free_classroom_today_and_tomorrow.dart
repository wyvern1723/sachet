import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sachet/providers/free_class_page_provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom_filter_options.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom_today_and_tomorrow.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/homepage_widgets/free_class_page_widgets/filter_fab.dart';
import 'package:provider/provider.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

List _classSessionList = ['12', '34', '56', '78', '091011'];

class FreeClassroomTodayAndTomorrow extends StatelessWidget {
  const FreeClassroomTodayAndTomorrow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FreeClassPageProvider(),
      child: FreeClassroomTodayAndTomorrowView(),
    );
  }
}

class FreeClassroomTodayAndTomorrowView extends StatefulWidget {
  const FreeClassroomTodayAndTomorrowView({super.key});

  @override
  State<FreeClassroomTodayAndTomorrowView> createState() =>
      _FreeClassroomTodayAndTomorrowViewState();
}

class _FreeClassroomTodayAndTomorrowViewState
    extends State<FreeClassroomTodayAndTomorrowView> {
  bool _showFab = true;

  void _handleScroll(ScrollController controller) {
    final direction = controller.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _showFab) {
      // 向下滑动, 隐藏 FAB
      setState(() => _showFab = false);
    } else if (direction == ScrollDirection.forward && !_showFab) {
      // 向上（向前）滑动，显示 FAB
      setState(() => _showFab = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('空闲教室'),
          bottom: const TabBar(
            tabs: [Tab(text: '今日'), Tab(text: '明日')],
          ),
          actions: <Widget>[
            TextButton.icon(
              style: Theme.of(context).useMaterial3
                  ? null
                  : TextButton.styleFrom(foregroundColor: Colors.white),
              icon: Icon(Icons.swap_horiz),
              onPressed: () {
                context
                    .read<SettingsProvider>()
                    .setIsFreeClassroomUseLegacyStyle(false);
              },
              label: Text('新版样式'),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _ClassroomDataView(
              day: Day.today,
              onScroll: _handleScroll,
            ),
            _ClassroomDataView(
              day: Day.tomorrow,
              onScroll: _handleScroll,
            )
          ],
        ),
        floatingActionButton: AnimatedSlide(
          offset: _showFab ? Offset(0, 0) : Offset(0, 2),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: FilterFAB(),
        ),
      ),
    );
  }
}

class _ClassroomDataView extends StatefulWidget {
  const _ClassroomDataView({
    required this.day,
    required this.onScroll,
  });

  final Day day;
  final void Function(ScrollController) onScroll;

  @override
  State<_ClassroomDataView> createState() => _ClassroomDataViewState();
}

//  使用 mixin 来保持 TabBarView 中页面的状态（包括滚动位置）
class _ClassroomDataViewState extends State<_ClassroomDataView>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  late Future<List> _dataFuture;

  @override
  bool get wantKeepAlive => true; // 启用状态保持

  Future<List> _getRoomData(
    ZhengFangUserProvider? zhengFangUserProvider,
  ) async {
    // 检查 filterOptions 是否有数据
    final filterOptions =
        context.read<FreeClassroomPageZFProvider>().filterOptions;
    if (filterOptions == null) {
      final result = await getFreeClassroomFilterOptionsZF(
        cookie: ZhengFangUserProvider.cookie,
        zhengFangUserProvider: zhengFangUserProvider,
      );
      context.read<FreeClassroomPageZFProvider>().setFilterOptions(result);
    }

    final String semesterYear =
        context.read<FreeClassroomPageZFProvider>().semesterYear;
    final String semesterIndex =
        context.read<FreeClassroomPageZFProvider>().semesterIndex;

    List<List<String>> freeClassroomData =
        await getFreeClassroomTodayAndTomorrowZF(
      cookie: ZhengFangUserProvider.cookie,
      semesterYear: semesterYear,
      semesterIndex: semesterIndex,
      day: widget.day,
      zhengFangUserProvider: zhengFangUserProvider,
    );
    if (!mounted) return [];
    context
        .read<FreeClassPageProvider>()
        .setAllClassroomsData(freeClassroomData, widget.day);
    context
        .read<FreeClassPageProvider>()
        .setClassroomsData(freeClassroomData, widget.day);
    context.read<FreeClassPageProvider>().setHasData();

    return freeClassroomData;
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void _onGoBack(dynamic value) {
    if (value == true) {
      // 登录成功后，重新获取数据并刷新UI
      setState(() {
        _dataFuture = _getRoomData(null);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _dataFuture = _getRoomData(zhengFangUserProvider);

    _scrollController = ScrollController();
    _scrollController.addListener(() => widget.onScroll(_scrollController));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            if (snapshot.error ==
                '获取可选数据失败: Http status code = 302, 可能需要重新登录') {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LoginExpiredZF(onGoBack: _onGoBack),
                ),
              );
            } else if (snapshot.error == '学期未开始' || snapshot.error == '学期已结束') {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_neutral_outlined, size: 30),
                        SizedBox(width: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await selectSemesterStartDate(context);
                      },
                      label: Text('设置学期开始日期'),
                      icon: Icon(Icons.edit_calendar_outlined),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }
          }

          return Column(
            children: [
              const _Head(),
              Expanded(
                child: _Body(
                  scrollController: _scrollController,
                  day: widget.day,
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// 表头，显示 「"节次","12","34","56","78","091011"」
class _Head extends StatelessWidget {
  const _Head();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            flex: 5,
            child: Container(
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.secondaryContainer,
              margin: const EdgeInsets.all(2.0),
              child: const Text("节次"),
            ),
          ),
          ...List.generate(
            5,
            (index) => Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                margin: const EdgeInsets.all(2.0),
                child: FittedBox(
                  child: Text(
                    "${_classSessionList[index]}",
                    style: TextStyle(fontSize: 10.0),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.day,
    required this.scrollController,
  });
  final Day day;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    late List freeClassroomsData;
    switch (day) {
      case Day.today:
        freeClassroomsData = context.select<FreeClassPageProvider, List>(
            (freeClassPageProvider) =>
                freeClassPageProvider.classroomDataToday);
        break;
      case Day.tomorrow:
        freeClassroomsData = context.select<FreeClassPageProvider, List>(
            (freeClassPageProvider) =>
                freeClassPageProvider.classroomDataTomorrow);
        break;
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: freeClassroomsData.length + 1,
      itemBuilder: (context, index) {
        if (index == freeClassroomsData.length) {
          return _Foot(); // 最后一个 item 是 Foot
        }
        return _ClassroomRow(rowData: freeClassroomsData[index]);
      },
    );
  }
}

/// 教室数据的一行
class _ClassroomRow extends StatelessWidget {
  const _ClassroomRow({required this.rowData});

  final List rowData;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 教室名
          Flexible(
            flex: 5,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
              margin: const EdgeInsets.all(2.0),
              child: Text("${rowData[0]}", textAlign: TextAlign.center),
            ),
          ),
          ...List.generate(5, (i) {
            final status = rowData[i + 1];
            switch (status) {
              case '空':
                return Flexible(
                  flex: 1,
                  child: Container(
                    color: Colors.green.shade400,
                    margin: EdgeInsets.all(2.0),
                  ),
                );
              case '满':
                return Flexible(
                  flex: 1,
                  child: Container(
                    color: Colors.red.shade400,
                    margin: EdgeInsets.all(2.0),
                  ),
                );
              default:
                return Flexible(
                  flex: 1,
                  child: Container(
                    color: Colors.grey.shade400,
                    margin: const EdgeInsets.all(2.0),
                    child: Text(status),
                  ),
                );
            }
          }),
        ],
      ),
    );
  }
}

class _Foot extends StatelessWidget {
  /// 脚注，"* 全天满课的教室不参与显示", 绿色方块: 空，红色方块: 满
  const _Foot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 16.0),
      child: Row(
        children: [
          Text(
            // '*仅显示有空闲时段的教室',
            // '*仅列出当天有空闲时段的教室',
            '* 全天满课的教室不参与显示',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 2, 0),
            child: Container(
              color: Colors.green.shade400,
              child: SizedBox.square(dimension: 16),
            ),
          ),
          Text(': 空', style: Theme.of(context).textTheme.bodySmall),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 2, 0),
            child: Container(
              color: Colors.red.shade400,
              child: SizedBox.square(dimension: 16),
            ),
          ),
          Text(': 满', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
