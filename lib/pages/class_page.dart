import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/models/nav_type.dart';
import 'package:sachet/pages/class_child_pages/single_month_page.dart';
import 'package:sachet/pages/class_child_pages/single_week_page.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/widgets/classpage_widgets/classpage_appbar.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClassPageProvider(),
      child: PopScope(
        canPop: AppGlobal.startupPage == '/class',
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          if (SettingsProvider.navigationType ==
              NavType.navigationDrawer.type) {
            Navigator.of(context).pushReplacementNamed(AppGlobal.startupPage);
          }
          context.read<ScreenNavProvider>().setCurrentPageToStartupPage();
        },
        child: Scaffold(
          drawer:
              SettingsProvider.navigationType == NavType.navigationDrawer.type
                  ? myNavDrawer
                  : null,
          appBar: ClassPageAppBar(),
          body: Selector<SettingsProvider, (String, Map?)>(
              selector: (_, settingsProvider) => (
                    settingsProvider.classScheduleFilePath,
                    settingsProvider.courseColorData,
                  ),
              builder: (_, __, ___) {
                return FutureBuilder(
                    future: context
                        .read<SettingsProvider>()
                        .loadCourseScheduleData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          if (kDebugMode) {
                            print(snapshot.error);
                          }
                          return Center(
                            child: Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          );
                        } else {
                          final data = snapshot.data;

                          return ClassPageView(
                            courseScheduleItemsList:
                                data?.courseScheduleItemsList,
                            courseColorData: data?.courseColorData,
                            classSessionSummerDataList:
                                data?.classSessionSummerDataList,
                            classSessionWinterDataList:
                                data?.classSessionWinterDataList,
                          );
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    });
              }),
        ),
      ),
    );
  }
}

class ClassPageView extends StatelessWidget {
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;
  final List? classSessionSummerDataList;
  final List? classSessionWinterDataList;

  const ClassPageView({
    super.key,
    required this.courseScheduleItemsList,
    required this.courseColorData,
    required this.classSessionSummerDataList,
    required this.classSessionWinterDataList,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ClassPageProvider, ClassScheduleViewMode>(
        selector: (_, provider) => provider.currentViewMode,
        builder: (_, currentViewMode, __) {
          switch (currentViewMode) {
            case ClassScheduleViewMode.week:
              return WeekView(
                courseScheduleItemsList: courseScheduleItemsList,
                courseColorData: courseColorData,
                classSessionSummerDataList: classSessionSummerDataList,
                classSessionWinterDataList: classSessionWinterDataList,
              );
            case ClassScheduleViewMode.month:
              return MonthView(
                courseScheduleItemsList: courseScheduleItemsList,
                courseColorData: courseColorData,
                classSessionSummerDataList: classSessionSummerDataList,
                classSessionWinterDataList: classSessionWinterDataList,
              );
          }
        });
  }
}

class WeekView extends StatefulWidget {
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;
  final List? classSessionSummerDataList;
  final List? classSessionWinterDataList;

  const WeekView({
    super.key,
    this.courseScheduleItemsList,
    this.courseColorData,
    this.classSessionSummerDataList,
    this.classSessionWinterDataList,
  });

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ClassPageProvider>()
          .pageController
          .jumpToPage(context.read<ClassPageProvider>().currentWeekCount - 1);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: context.read<ClassPageProvider>().pageController,
        onPageChanged: (value) {
          context.read<ClassPageProvider>().updateCurrentWeekCount(value + 1);
        },
        allowImplicitScrolling: true,
        children: [
          for (int i = 1; i < 21; i++)
            SingleWeekPage(
              weekCount: i,
              courseScheduleItemsList: widget.courseScheduleItemsList,
              courseColorData: widget.courseColorData,
              classSessionSummerDataList: widget.classSessionSummerDataList,
              classSessionWinterDataList: widget.classSessionWinterDataList,
            ),
        ]);
  }
}

class MonthView extends StatefulWidget {
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;
  final List? classSessionSummerDataList;
  final List? classSessionWinterDataList;

  const MonthView({
    super.key,
    this.courseScheduleItemsList,
    this.courseColorData,
    this.classSessionSummerDataList,
    this.classSessionWinterDataList,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentWeekCount =
          context.read<ClassPageProvider>().currentWeekCount;

      final currentMonth = getDateFromWeekCountAndWeekday(
        semesterStartDate: DateTime.parse(SettingsProvider.semesterStartDate),
        weekCount: currentWeekCount,
        weekday: 7,
      ).month;
      context.read<ClassPageProvider>().jumpToMonth(month: currentMonth);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<MonthData> monthList =
        context.select<ClassPageProvider, List<MonthData>>(
            (provider) => provider.monthList);

    return PageView(
      controller: context.read<ClassPageProvider>().pageController,
      onPageChanged: (value) {
        context.read<ClassPageProvider>().updateCurrentMonthByIndex(value);
      },
      allowImplicitScrolling: true,
      children: [
        for (final monthData in monthList)
          SingleMonthPage(
            month: monthData.month,
            monthDate: monthData.monthDate,
            courseScheduleItemsList: widget.courseScheduleItemsList,
            courseColorData: widget.courseColorData,
            classSessionSummerDataList: widget.classSessionSummerDataList,
            classSessionWinterDataList: widget.classSessionWinterDataList,
          ),
      ],
    );
  }
}
