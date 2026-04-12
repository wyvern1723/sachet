import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/widgets/classpage_widgets/course_card.dart';

class SemesterView extends StatefulWidget {
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;

  const SemesterView({
    super.key,
    this.courseScheduleItemsList,
    this.courseColorData,
  });

  @override
  State<SemesterView> createState() => _SemesterViewState();
}

class _SemesterViewState extends State<SemesterView> {
  double _aspectRatio = 1.5;
  double _baseAspectRatio = 1.5;
  int _pointerCount = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.courseScheduleItemsList == null) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;

    return Listener(
      onPointerDown: (event) => setState(() => _pointerCount++),
      onPointerUp: (event) => setState(() => _pointerCount--),
      onPointerCancel: (event) => setState(() => _pointerCount--),
      child: GestureDetector(
        onScaleStart: (details) {
          _baseAspectRatio = _aspectRatio;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount < 2) return;
          setState(() {
            _aspectRatio = (_baseAspectRatio / details.scale).clamp(0.3, 2.5);
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 0.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                  physics: _pointerCount >= 2
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  itemCount: 20,
                  padding: const EdgeInsets.only(bottom: 40),
                  itemBuilder: (context, index) {
                    final weekCount = index + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
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
                                aspectRatio: _aspectRatio,
                                child: Selector<SettingsProvider, String>(
                                    selector: (_, settingsProvider) =>
                                        SettingsProvider.semesterStartDate,
                                    builder: (_, semesterStartDate, __) {
                                      return _HeatmapCell(
                                        weekCount: weekCount,
                                        weekday: weekday,
                                        courseScheduleItemsList:
                                            widget.courseScheduleItemsList!,
                                        semesterStartDate: semesterStartDate,
                                        aspectRatio: _aspectRatio,
                                        courseColorData: widget.courseColorData,
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
        ),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final int weekCount;
  final int weekday;
  final List<List<CourseSchedule>> courseScheduleItemsList;
  final String semesterStartDate;
  final double aspectRatio;
  final Map? courseColorData;

  const _HeatmapCell({
    required this.weekCount,
    required this.weekday,
    required this.courseScheduleItemsList,
    required this.semesterStartDate,
    required this.aspectRatio,
    this.courseColorData,
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
    final bool showCourse = aspectRatio < 0.7;

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.0),
        border: today ? Border.all(color: colorScheme.primary, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment:
            showCourse ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Padding(
            padding:
                showCourse ? const EdgeInsets.only(top: 2.0) : EdgeInsets.zero,
            child: Text(
              '${date.month}/${date.day}',
              style: TextStyle(
                fontSize: showCourse ? 11 : 10,
                fontWeight: today ? FontWeight.bold : FontWeight.normal,
                color:
                    count > 4 ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ),
          if (showCourse)
            Expanded(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: Column(
                    children: [
                      for (int classCount = 0; classCount < 5; classCount++)
                        Builder(builder: (context) {
                          int item = (weekday - 1) * 5 + classCount;
                          List<CourseSchedule> courseScheduleItems =
                              courseScheduleItemsList[item];
                          final cardHeight = 10.0;

                          return SizedBox(
                            height: (cardHeight) * 2,
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: (cardHeight) * 11,
                              child: CourseCard.compact(
                                cardHeight: cardHeight,
                                cardBorderRadius: 4.0,
                                weekCount: weekCount,
                                weekday: weekday,
                                classCount: classCount,
                                courseScheduleItems: courseScheduleItems,
                                courseColorData: courseColorData,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
