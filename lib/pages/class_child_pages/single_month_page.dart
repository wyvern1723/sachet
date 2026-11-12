import 'package:flutter/material.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/course_layout_helper.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/widgets/classpage_widgets/course_card.dart';
import 'package:sachet/widgets/classpage_widgets/day_course_cards.dart';

class SingleMonthPage extends StatefulWidget {
  /// 为每月创建一个 SingleMonthPage
  const SingleMonthPage({
    super.key,
    required this.month,
    required this.monthDate,
    required this.courseScheduleItemsList,
    required this.courseColorData,
    required this.cardHeight,
    required this.pointerCount,
  });
  final int month;
  final DateTime monthDate;
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;
  final double cardHeight;
  final int pointerCount;
  @override
  State<SingleMonthPage> createState() => _SingleMonthPageState();
}

class _SingleMonthPageState extends State<SingleMonthPage> {
  List<DateTime> _calendarDays = [];

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
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
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
    // ignore: no_leading_underscores_for_local_identifiers
    final _isToday = isToday(date);

    /// 当天是否属于本月
    final isInCurrentMonth = date.month == month;
    // final showCourse = dayData.isInCurrentMonth && !dayData.isBeforeSemester;
    int weekCount = 0;
    if (widget.courseScheduleItemsList != null) {
      // 计算该日期对应的周次
      weekCount = getWeekCountAndWeekdayOfDate(
        semesterStartDate: SettingsProvider.classScheduleSemesterStartDate,
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
                  color: _isToday
                      ? colorScheme.onPrimary
                      : isInCurrentMonth
                          ? colorScheme.onSurface
                          : colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.courseScheduleItemsList != null)
              _buildCourseCards(date: date, weekCount: weekCount),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCards({required DateTime date, required int weekCount}) {
    final List<List<CourseSchedule>> courseScheduleItemsList =
        widget.courseScheduleItemsList!;

    final List<CourseCardLayout> courseLayouts = getDayCourseLayouts(
      courseScheduleItemsList: courseScheduleItemsList,
      weekday: date.weekday,
      weekCount: weekCount,
    );

    // 至少保留 8 节高度，有晚课时延伸到最晚结束节次
    int lastSession = 8;
    for (final courseLayout in courseLayouts) {
      if (courseLayout.endSession > lastSession) {
        lastSession = courseLayout.endSession;
      }
    }

    final double dayHeight = widget.cardHeight * lastSession;

    return DayCourseCards(
      courseLayouts: courseLayouts,
      courseScheduleItemsList: courseScheduleItemsList,
      weekday: date.weekday,
      weekCount: weekCount,
      cardHeight: widget.cardHeight,
      slotHeight: widget.cardHeight * 2,
      height: dayHeight,
      variant: CourseCardVariant.compact,
      courseColorData: widget.courseColorData,
    );
  }
}
