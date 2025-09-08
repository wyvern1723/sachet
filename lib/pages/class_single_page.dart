import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/services/time_manager.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/classpage_widgets/class_session_routine_column.dart';
import 'package:sachet/widgets/classpage_widgets/course_card.dart';
import 'package:sachet/widgets/classpage_widgets/day_of_the_week_topbar.dart';

class ClassSinglePage extends StatefulWidget {
  /// 为每周创建一个 ClassSinglePage
  const ClassSinglePage({
    super.key,
    required this.weekCount,
    required this.courseScheduleItemsList,
    required this.classSessionSummerDataList,
    required this.classSessionWinterDataList,
    required this.courseColorData,
  });
  final int weekCount;
  final List? courseScheduleItemsList;
  final Map courseColorData;
  final List classSessionSummerDataList;
  final List classSessionWinterDataList;
  @override
  State<ClassSinglePage> createState() => _ClassSinglePageState();
}

class _ClassSinglePageState extends State<ClassSinglePage> {
  @override
  Widget build(BuildContext context) {
    // 判断日期，如果在 5/1 - 9/30 采用夏季作息时间，其他的采用冬季作息时间
    // 夏季作息 (5.1 - 9.30) 下午2点半上课
    // 冬季作息 (10.1 - 4.30) 下午2点上课
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 顶部显示课程表的日期和星期
        Selector<SettingsProvider, String>(
            selector: (_, settingsProvider) =>
                SettingsProvider.semesterStartDate,
            builder: (_, semesterStartDate, __) {
              return DayOfTheWeekTopBar(
                weekCount: widget.weekCount,
                semesterStartDate: DateTime.tryParse(semesterStartDate) ??
                    constSemesterStartDate,
              );
            }),
        // 下方是课程表主体
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧显示课程的节次和时间
                Expanded(
                  flex: 4,
                  child: Selector<SettingsProvider, String>(
                      selector: (_, settingsProvider) =>
                          SettingsProvider.semesterStartDate,
                      builder: (_, semesterStartDate, __) {
                        int thisMonth = getTheMondayDateOfTheWeek(
                                DateTime.tryParse(semesterStartDate) ??
                                    constSemesterStartDate,
                                widget.weekCount)
                            .month;
                        bool isSummerRountine = thisMonth > 4 && thisMonth < 10;
                        return ClassSessionRoutineColumn(
                          weekCount: widget.weekCount,
                          routinedata: isSummerRountine
                              ? widget.classSessionSummerDataList
                              : widget.classSessionWinterDataList,
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
                        ? Column(
                            children: [
                              for (int classCount = 0;
                                  classCount < 5;
                                  classCount++)
                                Selector<CourseCardSettingsProvider, double>(
                                    selector: (_, courseCardSettingsProvider) =>
                                        courseCardSettingsProvider.cardHeight,
                                    builder: (context, cardHeight, __) {
                                      int item = (weekday - 1) * 5 + classCount;
                                      List list =
                                          widget.courseScheduleItemsList![item];
                                      List<CourseSchedule> courseScheduleItems =
                                          list
                                              .map((data) =>
                                                  CourseSchedule.fromJson(data))
                                              .toList();
                                      return SizedBox(
                                        height: (cardHeight) * 2,
                                        child: OverflowBox(
                                          alignment: Alignment.topCenter,
                                          maxHeight: (cardHeight) * 11,
                                          child: CourseCard(
                                            cardHeight: cardHeight,
                                            weekCount: widget.weekCount,
                                            weekday: weekday,
                                            classCount: classCount,
                                            courseScheduleItems:
                                                courseScheduleItems,
                                            courseColorData:
                                                widget.courseColorData,
                                          ),
                                        ),
                                      );
                                    }),
                            ],
                          )
                        : SizedBox(),
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
