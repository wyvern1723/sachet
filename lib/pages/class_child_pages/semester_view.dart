import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/time_manager.dart';

class SemesterView extends StatelessWidget {
  final List<List<CourseSchedule>>? courseScheduleItemsList;

  const SemesterView({
    super.key,
    this.courseScheduleItemsList,
  });

  @override
  Widget build(BuildContext context) {
    if (courseScheduleItemsList == null) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 0.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: FittedBox(
                  child: Center(
                    child: Text(
                      '周次',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              for (final day in ['一', '二', '三', '四', '五', '六', '日'])
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              padding: EdgeInsets.only(bottom: 40),
              itemBuilder: (context, index) {
                final weekCount = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(
                            '$weekCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      for (int weekday = 1; weekday <= 7; weekday++)
                        Expanded(
                          flex: 5,
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: Selector<SettingsProvider, String>(
                                selector: (_, settingsProvider) =>
                                    SettingsProvider.semesterStartDate,
                                builder: (_, semesterStartDate, __) {
                                  return _HeatmapCell(
                                    weekCount: weekCount,
                                    weekday: weekday,
                                    courseScheduleItemsList:
                                        courseScheduleItemsList!,
                                    semesterStartDate: semesterStartDate,
                                  );
                                }),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final int weekCount;
  final int weekday;
  final List<List<CourseSchedule>> courseScheduleItemsList;
  final String semesterStartDate;

  const _HeatmapCell({
    required this.weekCount,
    required this.weekday,
    required this.courseScheduleItemsList,
    required this.semesterStartDate,
  });

  @override
  Widget build(BuildContext context) {
    int count = 0;
    for (int sessionIndex = 0; sessionIndex < 5; sessionIndex++) {
      int item = (weekday - 1) * 5 + sessionIndex;
      if (item < courseScheduleItemsList.length) {
        for (final course in courseScheduleItemsList[item]) {
          if (course.weeks?.contains(weekCount) ?? false) {
            count++;
          }
        }
      }
    }

    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    if (count == 0) {
      color = colorScheme.surfaceContainerHighest.withOpacity(0.4);
    } else {
      double opacity = (count / 5).clamp(0.2, 1.0);
      color = colorScheme.primary.withOpacity(opacity);
    }

    final DateTime date = getDateFromWeekCountAndWeekday(
      semesterStartDate:
          DateTime.tryParse(semesterStartDate) ?? constSemesterStartDate,
      weekCount: weekCount,
      weekday: weekday,
    );
    final bool today = isToday(date);

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
        border: today ? Border.all(color: colorScheme.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${date.month}/${date.day}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: today ? FontWeight.bold : FontWeight.normal,
            color: count > 4 ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
