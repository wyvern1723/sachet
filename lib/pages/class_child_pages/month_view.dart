import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/pages/class_child_pages/single_month_page.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/time_manager.dart';

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
