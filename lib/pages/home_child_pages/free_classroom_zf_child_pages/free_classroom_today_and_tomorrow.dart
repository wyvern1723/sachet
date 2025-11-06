import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:sachet/providers/free_class_page_provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/time_manager.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom_filter_options.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom_full_day.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom_today_and_tomorrow.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/homepage_widgets/free_class_page_widgets/filter_fab.dart';
import 'package:provider/provider.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

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
    extends State<FreeClassroomTodayAndTomorrowView>
    with TickerProviderStateMixin {
  bool _showFab = true;

  TabController? _tabController;
  List<Widget> _tabs = [];
  List<Widget> _tabViews = [];

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

  /// 选择日期并跳转到选择的日期的一页
  Future _selectAndAddDate() async {
    final firstDate = getDateFromWeekCountAndWeekday(
      semesterStartDate: DateTime.parse(SettingsProvider.semesterStartDate),
      weekCount: 1,
      weekday: 1,
    );
    final lastDate = getDateFromWeekCountAndWeekday(
      semesterStartDate: DateTime.parse(SettingsProvider.semesterStartDate),
      weekCount: 20,
      weekday: 7,
    );
    final pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('zh', 'CN'),
      initialDate: DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: '选择日期',
    );
    if (pickedDate != null) {
      // 当前 Tab 的 index
      final int newIndex = _tabs.length - 1;

      // 新的刚刚选择的日期的空闲教室 TabView
      final newPage = _ClassroomDataView(
        date: pickedDate,
        index: newIndex - 2,
        onScroll: _handleScroll,
      );

      setState(() {
        // 在 Tab 和 TabView 插入选择的日期
        // e.g. 1
        // 插入前: [今日, 明日, 自选日期]
        // 插入后: [今日, 明日, 11/08, 自选日期]
        //
        // e.g. 2
        // 插入前: [今日, 明日, 11/08, 自选日期]
        // 插入后: [今日, 明日, 11/08, 11/09, 自选日期]
        _tabs.insert(
            newIndex, Tab(text: DateFormat('MM/dd').format(pickedDate)));
        _tabViews.insert(newIndex, newPage);

        final int previousIndex = _tabController!.index;
        // 重新创建 TabController
        _recreateTabController(initialIndex: previousIndex);
      });

      // 跳转到刚刚选择的日期的一页
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController != null && _tabController!.length > newIndex) {
          _tabController!.animateTo(newIndex);
        }
      });
    }
  }

  /// 重新创建 TabController（主要是更新 length）
  void _recreateTabController({int initialIndex = 0}) {
    _tabController?.dispose();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabs = [
      Tab(text: '今日'),
      Tab(text: '明日'),
      Tab(
        child: Row(
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.edit_calendar_outlined,
                size: 20,
                // color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 4),
            Text('自选日期'),
          ],
        ),
      )
    ];
    _tabViews = [
      _ClassroomDataView(
        day: Day.today,
        onScroll: _handleScroll,
      ),
      _ClassroomDataView(
        day: Day.tomorrow,
        onScroll: _handleScroll,
      ),
      Container(), // 占位，和 "自选日期" 对应，不会展示
    ];
    // 创建初始的 TabController
    _recreateTabController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // 处理 Tab 点击事件
  void _handleTabTap(int index) {
    // 判断点击的是否是最后一个 Tab (即“自选日期”)
    if (index == _tabs.length - 1) {
      // 阻止默认的切换行为
      _tabController!.index = _tabController!.previousIndex;
      // 选择日期并添加这个自选日期
      _selectAndAddDate();
    }
  }

  /// 给筛选按钮筛选的 map(因为可以自定义查询节次分段,所以需要动态生成)
  ///
  /// e.g.
  ///
  /// ```dart
  /// {
  ///   '12': 1,
  ///   '34': 2,
  ///   '56': 3,
  ///   '78': 4,
  ///   '9 10 11': 5,
  /// };
  /// ```
  ///
  /// /// ```dart
  /// {
  ///   '12': 1,
  ///   '34': 2,
  ///   '56': 3,
  ///   '78': 4,
  ///   '910': 5,
  ///   '11': 6,
  /// };
  /// ```
  Map<String, int> _sessionFilter() {
    Map<String, int> sessionFilter = {};
    List sections =
        List.from(context.read<SettingsProvider>().freeClassroomSections);
    List<List<int>> convertedList =
        sections.map((innerList) => List<int>.from(innerList)).toList();
    for (var i = 0; i < convertedList.length; i++) {
      sessionFilter.addAll({convertedList[i].join(''): i + 1});
    }
    return sessionFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('空闲教室'),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          onTap: _handleTabTap,
          tabs: _tabs,
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
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _tabViews,
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset(0, 0) : Offset(0, 2),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: FilterFAB(sessionFilter: _sessionFilter()),
      ),
    );
  }
}

class _ClassroomDataView extends StatefulWidget {
  /// 如果 [day] != null,表示是 今日或明日
  ///
  /// 否则需要提供 [date] 和 [index]，表示是 自选日期
  const _ClassroomDataView({
    this.day,
    this.date,
    this.index,
    required this.onScroll,
  }) : assert(
          day != null || date != null && index != null,
          '必须提供 day 或 date + index',
        );

  /// 今日或明日
  final Day? day;

  /// 自选日期
  final DateTime? date;

  /// 新增的第几个自选日期，从 0 开始。例如新增的第一个自选日期的 index = 0;
  final int? index;
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

    final Day? day = widget.day;
    final DateTime? date = widget.date;
    List sections =
        List.from(context.read<SettingsProvider>().freeClassroomSections);
    if (day != null) {
      List<List<String>> freeClassroomData =
          await getFreeClassroomTodayAndTomorrowZF(
        cookie: ZhengFangUserProvider.cookie,
        semesterYear: semesterYear,
        semesterIndex: semesterIndex,
        day: day,
        itemList: sections,
        zhengFangUserProvider: zhengFangUserProvider,
      );
      if (!mounted) return [];
      context
          .read<FreeClassPageProvider>()
          .setAllClassroomsDataForTodayOrTomorrow(freeClassroomData, day);
      context
          .read<FreeClassPageProvider>()
          .setClassroomsDataForTodayOrTomorrow(freeClassroomData, day);
      context.read<FreeClassPageProvider>().setHasData();

      return freeClassroomData;
    } else if (date != null) {
      List<List<String>> freeClassroomData = await getFreeClassroomFullDayZF(
        cookie: ZhengFangUserProvider.cookie,
        semesterYear: semesterYear,
        semesterIndex: semesterIndex,
        date: date,
        itemList: sections,
        zhengFangUserProvider: zhengFangUserProvider,
      );
      if (!mounted) return [];
      context
          .read<FreeClassPageProvider>()
          .setAllClassroomsDataForOtherDay(freeClassroomData);
      context
          .read<FreeClassPageProvider>()
          .setClassroomsDataForOtherDay(freeClassroomData);
      context.read<FreeClassPageProvider>().setHasData();

      return freeClassroomData;
    } else {
      throw '必须提供 day 或 date';
    }
  }

  /// 表头显示的节次(因为可以自定义查询节次分段,所以需要动态生成)
  ///
  /// e.g. ['12', '34', '56', '78', '91011'];
  ///
  /// e.g. ['12', '34', '56', '78', '910', '11'];
  List _sessionList() {
    List sessionList = [];

    List sections =
        List.from(context.read<SettingsProvider>().freeClassroomSections);
    List<List<int>> convertedList =
        sections.map((innerList) => List<int>.from(innerList)).toList();
    for (var i = 0; i < convertedList.length; i++) {
      sessionList.add(convertedList[i].join(''));
    }

    return sessionList;
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
              _Head(sessionList: _sessionList()),
              Expanded(
                child: widget.day != null
                    ? _BodyOfTodayOrTomorrow(
                        scrollController: _scrollController,
                        day: widget.day!,
                      )
                    : _BodyOfOtherDay(
                        scrollController: _scrollController,
                        index: widget.index!,
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
  final List sessionList;
  const _Head({required this.sessionList});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            flex: sessionList.length,
            child: Container(
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.secondaryContainer,
              margin: const EdgeInsets.all(2.0),
              child: const Text("节次"),
            ),
          ),
          ...List.generate(
            sessionList.length,
            (index) => Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                margin: const EdgeInsets.all(2.0),
                child: FittedBox(
                  child: Text(
                    "${sessionList[index]}",
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

class _BodyOfTodayOrTomorrow extends StatelessWidget {
  /// 今日或明日的 Body
  const _BodyOfTodayOrTomorrow({
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
            (freeClassPageProvider) => freeClassPageProvider.filteredDataToday);
        break;
      case Day.tomorrow:
        freeClassroomsData = context.select<FreeClassPageProvider, List>(
            (freeClassPageProvider) =>
                freeClassPageProvider.filteredDataTomorrow);
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

class _BodyOfOtherDay extends StatelessWidget {
  /// 自选日期的 Body
  const _BodyOfOtherDay({
    required this.index,
    required this.scrollController,
  });
  final int index;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    late List freeClassroomsData;

    freeClassroomsData = context.select<FreeClassPageProvider, List>(
        (freeClassPageProvider) =>
            freeClassPageProvider.filteredDataOtherDays[index]);

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
            flex: rowData.length - 1,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
              margin: const EdgeInsets.all(2.0),
              child: Text("${rowData[0]}", textAlign: TextAlign.center),
            ),
          ),
          ...List.generate(rowData.length - 1, (i) {
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
