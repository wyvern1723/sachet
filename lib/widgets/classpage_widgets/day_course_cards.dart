import 'package:flutter/material.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/utils/course_layout_helper.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/widgets/classpage_widgets/course_card.dart';

/// 按节次和分列位置排列一天的课程卡片
class DayCourseCards extends StatelessWidget {
  const DayCourseCards({
    super.key,
    required this.courseLayouts,
    required this.courseScheduleItemsList,
    required this.weekday,
    required this.weekCount,
    required this.cardHeight,
    required this.courseColorData,
    required this.slotHeight,
    this.height,
    this.variant = CourseCardVariant.normal,
    this.cardBorderRadius,
  });

  final List<CourseCardLayout> courseLayouts;
  final List<List<CourseSchedule>> courseScheduleItemsList;
  final int weekday;
  final int weekCount;
  final double cardHeight;
  final Map? courseColorData;

  /// 每个时间段（[CourseCardLayout.classCount]）在纵向上占用的高度。
  /// 周视图需要把大课间的间隙也算进去。
  final double slotHeight;

  /// 卡片区域的固定高度
  final double? height;

  final CourseCardVariant variant;
  final double? cardBorderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double dayWidth = constraints.maxWidth;
        final Widget stack = Stack(
          clipBehavior: Clip.none,
          children: [
            for (final layout in courseLayouts)
              Positioned(
                top: layout.classCount * slotHeight,
                left: dayWidth * layout.columnIndex / layout.columnCount,
                width: dayWidth / layout.columnCount,
                child: CourseCard(
                  variant: variant,
                  cardHeight: cardHeight,
                  cardBorderRadius: cardBorderRadius,
                  weekCount: weekCount,
                  weekday: weekday,
                  classCount: layout.classCount,
                  courseScheduleItems: courseScheduleItemsList[
                      getItemFromWeekdayAndClassCount(
                          weekday, layout.classCount)],
                  displayCourseSchedule: layout.courseSchedule,
                  courseColorData: courseColorData,
                ),
              ),
          ],
        );

        return height == null ? stack : SizedBox(height: height, child: stack);
      },
    );
  }
}
