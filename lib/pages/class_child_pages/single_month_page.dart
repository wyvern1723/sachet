import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/widgets/classpage_widgets/course_card.dart';

class SingleMonthPage extends StatefulWidget {
  /// 为每月创建一个 SingleMonthPage
  const SingleMonthPage({
    super.key,
    required this.month,
    required this.monthDate,
    required this.courseScheduleItemsList,
    required this.classSessionSummerDataList,
    required this.classSessionWinterDataList,
    required this.courseColorData,
    required this.cardHeight,
    required this.pointerCount,
  });
  final int month;
  final DateTime monthDate;
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;
  final List? classSessionSummerDataList;
  final List? classSessionWinterDataList;
  final double cardHeight;
  final int pointerCount;
  @override
  State<SingleMonthPage> createState() => _SingleMonthPageState();
}

class _SingleMonthPageState extends State<SingleMonthPage> {
  List<DateTime> _calendarDays = [];

  /// 晚上的课（9,10,11 节）的 ItemIndex 列表
  /// item:
  ///
  ///       Mon Tue Wed Thu Fri Sat Sun
  /// 12      0   5  10  15  20  25  30
  /// 34      1   6  11  16  21  26  31
  /// 56      2   7  12  17  22  27  32
  /// 78      3   8  13  18  23  28  33
  /// 91011   4   9  14  19  24  29  34
  static const List _nightCourseItemIndexes = [4, 9, 14, 19, 24, 29, 34];

  /// 构建一个月完整的日历日期列表（含上月/下月补全）
  void _buildCalendarDays() {
    final monthDate = widget.monthDate;

    /// 本月第一天(x月1日)
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);

    /// 本月最后一天(x月31/30/29/28日)
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 1)
        .subtract(Duration(days: 1));

    /// 上月最后一天( x-1 月 31/30/29/28 日)
    final prevMonthLastDay = DateTime(monthDate.year, monthDate.month, 0);

    /// 显示的总行数
    // final int totalRows = ((firstDayOfMonth - 1 + lastDayOfMonth.day) / 7).ceil();

    /// 本月第一天是星期几
    final firstWeekday = firstDayOfMonth.weekday;
    final emptyDays = firstWeekday - 1; // 前面需要补全的天数

    final List<DateTime> days = [];

    // 添加上月补全日期
    for (int i = emptyDays; i > 0; i--) {
      final day = prevMonthLastDay.day - i + 1;
      final date = DateTime(monthDate.year, monthDate.month - 1, day);
      days.add(date);
    }

    // 添加当月日期
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(monthDate.year, monthDate.month, day);
      days.add(date);
    }

    // 添加下月补全日期（凑满 7 的倍数）
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int day = 1; day <= remainingDays; day++) {
        final date = DateTime(monthDate.year, monthDate.month + 1, day);
        days.add(date);
      }
    }

    _calendarDays = days;
  }

  @override
  void initState() {
    super.initState();
    _buildCalendarDays();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 周一 周二 周三 周四 周五 周六 周日
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0.0),
          child: Row(
            children: [
              for (int weekday = 1; weekday <= DateTime.daysPerWeek; weekday++)
                Expanded(
                  flex: 5,
                  child: Text(
                    weekdayToZhouJi[weekday].toString(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: widget.pointerCount >= 2
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 20.0),
              child: Column(
                children: [
                  for (int i = 0; i < _calendarDays.length; i += 7)
                    _buildWeekRow(
                      _calendarDays.sublist(i, i + 7),
                      widget.month,
                      context,
                      colorScheme,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekRow(
    List<DateTime> days,
    int month,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final day in days) _buildDayCell(day, month, context, colorScheme)
    ]);
  }

  Widget _buildDayCell(
    DateTime date,
    int month,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final _isToday = isToday(date);

    /// 当天是否属于本月
    final isInCurrentMonth = date.month == month;
    // final showCourse = dayData.isInCurrentMonth && !dayData.isBeforeSemester;
    int weekCount = 0;
    if (widget.courseScheduleItemsList != null) {
      // 计算该日期对应的周次
      weekCount = getWeekCountAndWeekdayOfDate(
        semesterStartDate:
            DateTime.tryParse(SettingsProvider.semesterStartDate) ??
                constSemesterStartDate,
        date: date,
      ).weekCount;
    }

    return Expanded(
      flex: 5,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: _isToday
                  ? BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                "${date.day}",
                style: TextStyle(
                  fontSize: 13,
                  height: 1.0,
                  color: !isInCurrentMonth
                      ? colorScheme.outline
                      : _isToday
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.courseScheduleItemsList != null) ...[
              for (int classCount = 0; classCount < 5; classCount++)
                Builder(builder: (context) {
                  int item = (date.weekday - 1) * 5 + classCount;
                  List<CourseSchedule> courseScheduleItems =
                      widget.courseScheduleItemsList![item];

                  int courseLength = 2;
                  int index = courseScheduleItems.indexWhere(
                      (element) => element.weeks!.contains(weekCount) == true);
                  if (index != -1) {
                    courseLength = courseScheduleItems[index].length ?? 2;
                  }

                  // 如果这一周完全没有晚课，不显示这一周所有的晚课的空白占位
                  // 其他课，即使没有课，也会有占位的空白，以保证剩下的课在正确的位置上
                  // 但如果是晚课，可以不显示，不会对课程的排列造成影响
                  // 如果整周都没有晚课，则可以不显示这一周所有晚课的空白占位，能够节省月视图下稀缺的空间

                  /// 这节课是否是晚课（显示在 **这个位置上** 的课是否是晚课，不一定有课）
                  final isNightCourse = _nightCourseItemIndexes.contains(item);

                  // 如果这节课是晚课，判断这一周是否每天晚上都没有课
                  if (isNightCourse) {
                    /// 这一周是否每天晚上都没有课
                    final isWeekHasNoNightCourse = _thisWeekHasNoNightCourses(
                      weekCount: weekCount,
                      courseScheduleItemsList: widget.courseScheduleItemsList!,
                      nightCourseItemIndexs: _nightCourseItemIndexes,
                    );

                    // 如果这一周没有一节晚课，则不显示 9,10,11 节课的空占位
                    if (isWeekHasNoNightCourse) {
                      return SizedBox();
                    }
                  }
                  return SizedBox(
                    height: isNightCourse
                        ? (widget.cardHeight * courseLength)
                        : (widget.cardHeight * 2),
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: (widget.cardHeight) * 11,
                      child: CourseCard.compact(
                        cardHeight: widget.cardHeight,
                        weekCount: weekCount,
                        weekday: date.weekday,
                        classCount: classCount,
                        courseScheduleItems: courseScheduleItems,
                        courseColorData: widget.courseColorData,
                      ),
                    ),
                  );
                }),
            ]
          ],
        ),
      ),
    );
  }
}

/// 这一周是否每天晚上都没有课（晚课：9,10,11 节）
///
/// true: 这一周完全没有晚课
///
/// false: 这一周至少有一天有晚课
bool _thisWeekHasNoNightCourses({
  required int weekCount,
  required List<List<CourseSchedule>> courseScheduleItemsList,
  required List nightCourseItemIndexs,
}) {
  for (final nightCourseItemIndex in nightCourseItemIndexs) {
    final List<CourseSchedule> courseScheduleItems =
        courseScheduleItemsList[nightCourseItemIndex];
    if (courseScheduleItems.isEmpty) {
      continue;
    }
    int index = courseScheduleItems
        .indexWhere((e) => e.weeks!.contains(weekCount) == true);
    if (index == -1) {
      continue;
    } else {
      CourseSchedule courseSchedule = courseScheduleItems[index];
      if (courseSchedule.title == null || courseSchedule.title == '') {
        continue;
      } else {
        return false;
      }
    }
  }

  return true;
}
