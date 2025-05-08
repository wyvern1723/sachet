import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sachet/provider/free_class_page_provider.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/model/get_web_data/process_data/get_free_class.dart';
import 'package:sachet/widgets/homepage_widgets/free_class_page_widgets/filter_fab.dart';
import 'package:sachet/widgets/utils_widgets/login_expired.dart';
import 'package:provider/provider.dart';

List _classSessionList = ['12', '34', '56', '78', '091011'];

class FreeClassPage extends StatelessWidget {
  const FreeClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FreeClassPageProvider(),
      child: FreeClassPageView(),
    );
  }
}

class FreeClassPageView extends StatefulWidget {
  const FreeClassPageView({super.key});

  @override
  State<FreeClassPageView> createState() => _FreeClassPageViewState();
}

class _FreeClassPageViewState extends State<FreeClassPageView> {
  late Future<List> futureRoomToday;
  late Future<List> futureRoomTomorrow;
  final PageStorageKey _pageStorageKey = PageStorageKey('key');

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      setState(() {
        futureRoomToday = getRoomData(Day.today);
        futureRoomTomorrow = getRoomData(Day.tomorrow);
      });
    }
  }

  Future<List> getRoomData(Day day) async {
    List<List<String>> freeClassRoomData = await getFreeClassData(day);
    context
        .read<FreeClassPageProvider>()
        .setAllClassroomsData(freeClassRoomData, day);
    context
        .read<FreeClassPageProvider>()
        .setClassroomsData(freeClassRoomData, day);
    context.read<FreeClassPageProvider>().setHasData();
    return freeClassRoomData;
  }

  @override
  void initState() {
    futureRoomToday = getRoomData(Day.today);
    futureRoomTomorrow = getRoomData(Day.tomorrow);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isShowOccupiedOrEmptyText = context.select<SettingsProvider, bool>(
        (settingsProvider) => settingsProvider.isShowOccupiedOrEmptyText);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('空闲教室'),
          bottom: const TabBar(
            tabs: [Tab(text: '今日'), Tab(text: '明日')],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(isShowOccupiedOrEmptyText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              tooltip: isShowOccupiedOrEmptyText ? '隐藏文字' : '显示文字',
              onPressed: () {
                context
                    .read<SettingsProvider>()
                    .toggleIsShowOccupiedOrEmptyText();
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            FutureBuilder(
              future: futureRoomToday,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    if (snapshot.error == '登录失效，请重新登录') {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: LoginExpired(
                            onGoBack: (value) => onGoBack(value),
                          ),
                        ),
                      );
                    } else {
                      return Text('${snapshot.error}');
                    }
                  } else {
                    return FreeRoomsColumn(
                      listViewKey: _pageStorageKey,
                      day: Day.today,
                    );
                  }
                }
                // By default, show a loading spinner.
                return const Center(child: CircularProgressIndicator());
              },
            ),
            FutureBuilder(
              future: futureRoomTomorrow,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    if (snapshot.error == '登录失效，请重新登录') {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: LoginExpired(
                            onGoBack: (value) => onGoBack(value),
                          ),
                        ),
                      );
                    } else {
                      return Text('${snapshot.error}');
                    }
                  } else {
                    return FreeRoomsColumn(
                      listViewKey: _pageStorageKey,
                      day: Day.tomorrow,
                    );
                  }
                }
                // By default, show a loading spinner.
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
        floatingActionButton: FilterFAB(),
      ),
    );
  }
}

class FreeRoomsColumn extends StatelessWidget {
  const FreeRoomsColumn({
    super.key,
    required this.listViewKey,
    required this.day,
  });
  final Key listViewKey;
  final Day day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Head(),
        Flexible(
          child: _Body(
            listViewKey: listViewKey,
            day: day,
          ),
        ),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Builder(builder: (context) {
            return Flexible(
              flex: 5,
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                margin: const EdgeInsets.all(2.0),
                child: const Text("节次"),
              ),
            );
          }),
          ...List.generate(
            5,
            (index) => Builder(builder: (context) {
              return Flexible(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  margin: const EdgeInsets.all(2.0),
                  child: Text(
                    "${_classSessionList[index]}",
                    style: TextStyle(fontSize: 10.0),
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({super.key, required this.listViewKey, required this.day});
  final Key listViewKey;
  final Day day;

  @override
  Widget build(BuildContext context) {
    bool isShowOccupiedOrEmptyText = context.select<SettingsProvider, bool>(
        (settingsProvider) => settingsProvider.isShowOccupiedOrEmptyText);
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

    List<Widget> buildRow(int index, List list) {
      return [
        // 教室名
        Builder(
          builder: (BuildContext context) => Flexible(
            flex: 5,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
              margin: const EdgeInsets.all(2.0),
              child: Text("${list[index][0]}", textAlign: TextAlign.center),
            ),
          ),
        ),
        ...List.generate(
          5,
          (i) => list[index][i + 1] == '空'
              ? Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.green.shade400,
                    margin: const EdgeInsets.all(2.0),
                    child: Text(isShowOccupiedOrEmptyText ? '空' : ''),
                  ),
                )
              : Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.red.shade400,
                    margin: const EdgeInsets.all(2.0),
                    child: Text(isShowOccupiedOrEmptyText ? '满' : ''),
                  ),
                ),
        )
      ];
    }

    List<Widget> buildRows(List list) {
      final count = list.length;
      return List.generate(
        count,
        (index) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildRow(index, list),
          ),
        ),
      );
    }

    return ListView(
      key: listViewKey,
      children: buildRows(freeClassroomsData),
    );
  }
}
