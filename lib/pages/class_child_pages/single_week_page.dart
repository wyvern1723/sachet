import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/models/session_routine.dart';
import 'package:sachet/utils/course_layout_helper.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/classpage_widgets/class_session_routine_column.dart';
import 'package:sachet/widgets/classpage_widgets/day_course_cards.dart';
import 'package:sachet/widgets/classpage_widgets/day_of_the_week_topbar.dart';

class SingleWeekPage extends StatefulWidget {
  /// 为每周创建一个 SingleWeekPage
  const SingleWeekPage({
    super.key,
    required this.weekCount,
    required this.courseScheduleItemsList,
    required this.courseColorData,
    required this.cardHeight,
    required this.pointerCount,
  });
  final int weekCount;
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;
  final double cardHeight;
  final int pointerCount;
  @override
  State<SingleWeekPage> createState() => _SingleWeekPageState();
}

class _SingleWeekPageState extends State<SingleWeekPage> {
  @override
  Widget build(BuildContext context) {
    // 判断日期，如果在 5/1 - 9/30 采用夏季作息时间，其他的采用冬季作息时间
    // 夏季作息 (5.1 - 9.30) 下午2点半上课
    // 冬季作息 (10.1 - 4.30) 下午2点上课
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 顶部显示课程表的日期和星期
        Selector<SettingsProvider, DateTime>(
            selector: (_, settingsProvider) =>
                SettingsProvider.classScheduleSemesterStartDate,
            builder: (_, semesterStartDate, __) {
              return DayOfTheWeekTopBar(
                weekCount: widget.weekCount,
                semesterStartDate: semesterStartDate,
              );
            }),
        // 下方是课程表主体
        Expanded(
          child: SingleChildScrollView(
            physics: widget.pointerCount >= 2
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧显示课程的节次和时间
                Expanded(
                  flex: 4,
                  child: Selector<SettingsProvider, DateTime>(
                      selector: (_, settingsProvider) =>
                          SettingsProvider.classScheduleSemesterStartDate,
                      builder: (_, semesterStartDate, __) {
                        /// 这周的周一的日期
                        final DateTime thisWeekMondayDate =
                            getTheMondayDateOfTheWeek(
                                semesterStartDate, widget.weekCount);

                        return ClassSessionRoutineColumn(
                          routineData: SessionRoutine(
                            date: thisWeekMondayDate,
                            isStaggered: false,
                          ).periods,
                          cardHeight: widget.cardHeight,
                        );
                      }),
                ),

                // 右侧是课程表的卡片区域
                for (int weekday = 1;
                    weekday <= DateTime.daysPerWeek;
                    weekday++)
                  Expanded(
                    flex: 5,
                    // 这里是一星期的每一天
                    child: widget.courseScheduleItemsList != null
                        ? _buildDayColumn(weekday: weekday)
                        : const SizedBox(),
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDayColumn({required int weekday}) {
    final List<CourseCardLayout> courseLayouts = getDayCourseLayouts(
      courseScheduleItemsList: widget.courseScheduleItemsList!,
      weekday: weekday,
      weekCount: widget.weekCount,
    );

    /// 每个时间段占用的垂直高度：2 个节次 + 一个大课间
    final double slotHeight =
        widget.cardHeight * 2 + widget.cardHeight * breakHeightRatio;

    return DayCourseCards(
      courseLayouts: courseLayouts,
      courseScheduleItemsList: widget.courseScheduleItemsList!,
      weekday: weekday,
      weekCount: widget.weekCount,
      cardHeight: widget.cardHeight,
      slotHeight: slotHeight,
      // 11 个节次 + 2 个大课间 + 午间休息 + 晚间休息的高度，与最左侧节次和时间的列一致
      height: widget.cardHeight * 11 + widget.cardHeight * breakHeightRatio * 4,
      courseColorData: widget.courseColorData,
    );
  }
}
