import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
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
  static const double _minCardHeight = 5.0;
  static const double _maxCardHeight = 50.0;

  double _cardHeight = 10.0;
  double _baseCardHeight = 10.0;
  int _pointerCount = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentWeekCount =
          context.read<ClassPageProvider>().currentWeekCount;

      final currentMonth = getDateFromWeekCountAndWeekday(
        semesterStartDate:
            DateTime.tryParse(SettingsProvider.semesterStartDate) ??
                constSemesterStartDate,
        weekCount: currentWeekCount,
        weekday: DateTime.now().weekday,
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

    return Listener(
      onPointerDown: (event) => setState(() => _pointerCount++),
      onPointerUp: (event) => setState(() => _pointerCount--),
      onPointerCancel: (event) => setState(() => _pointerCount--),
      child: GestureDetector(
        onScaleStart: (details) {
          _baseCardHeight = _cardHeight;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount < 2) return;
          setState(() {
            _cardHeight = (_baseCardHeight * details.scale)
                .clamp(_minCardHeight, _maxCardHeight);
          });
        },
        child: PageView(
          controller: context.read<ClassPageProvider>().pageController,
          onPageChanged: (value) {
            context.read<ClassPageProvider>().updateCurrentMonthByIndex(value);
          },
          physics: _pointerCount >= 2
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
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
                cardHeight: _cardHeight,
                pointerCount: _pointerCount,
              ),
          ],
        ),
      ),
    );
  }
}
