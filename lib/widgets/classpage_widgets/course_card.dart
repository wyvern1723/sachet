import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';
import 'package:sachet/utils/course_info_helper.dart';
import 'package:sachet/widgets/settingspage_widgets/customize_settings_widgets/set_course_card_appearance.dart';
import 'package:provider/provider.dart';

import '../../utils/transform.dart';
import 'course_card_item.dart';

class CourseCard extends StatelessWidget {
  final double cardHeight;
  final int weekCount;
  final int weekday;
  final int classCount; // classCount 节次（ 1~5 ）
  final List<CourseSchedule> courseScheduleItems;
  final Map courseColorData;
  const CourseCard({
    super.key,
    required this.cardHeight,
    required this.weekCount,
    required this.weekday,
    required this.classCount,
    required this.courseScheduleItems,
    required this.courseColorData,
  });

  void _showCourseDetails({
    required BuildContext context,
    required String courseTitle,
    required int weekday,
    required int classcount,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        List weeks = CourseInfoHelper.getWeeksOfCourse(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        List lengths = CourseInfoHelper.getLengths(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        List instructors = CourseInfoHelper.getInstructors(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        List places = CourseInfoHelper.getPlaces(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        List sectionsShowText = [];
        lengths.forEach((element) => sectionsShowText.add(
            '${classCountToSection[classcount]}~${classCountToSection[classcount]! + element - 1}节次'));
        return SingleChildScrollView(
          child: SelectionArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 6),
                ListTile(
                  leading: const Icon(Icons.class_),
                  title: Text(courseTitle),
                ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(instructors.join(' / ')),
                ),
                ListTile(
                  leading: const Icon(Icons.room),
                  title: Text(places.join(' / ')),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text('${weekdayToXingQiJi[weekday]} '
                      '${sectionsShowText.join(' / ')}'),
                ),
                const ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text('周次：'),
                ),
                SelectionContainer.disabled(
                  child: Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        // alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 8,
                        direction: Axis.horizontal,
                        children: [
                          ...List.generate(20, (index) {
                            int weekCount = index + 1;
                            return Ink(
                              height: 38,
                              width: 38,
                              color: weeks.contains(weekCount)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              child: Center(
                                  child: Text(
                                '$weekCount',
                                style: TextStyle(
                                  color: weeks.contains(weekCount)
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              )),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16)
              ],
            ),
          ),
        );
      },
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (courseScheduleItems.isEmpty) {
      return SizedBox();
    }

    int index = courseScheduleItems
        .indexWhere((element) => element.weeks!.contains(weekCount) == true);

    if (index == -1) {
      return SizedBox();
    } else {
      CourseSchedule courseSchedule = courseScheduleItems[index];

      if (courseSchedule.title == null || courseSchedule.title == '') {
        return SizedBox();
      }

      return CourseCardWidget(
          courseColorData: courseColorData,
          courseSchedule: courseSchedule,
          onTap: (_) {
            _showCourseDetails(
              context: context,
              courseTitle: courseSchedule.title ?? '',
              weekday: weekday,
              classcount: classCount,
            );
          });
    }
  }
}

class CourseCardWidget extends StatelessWidget {
  const CourseCardWidget({
    super.key,
    required this.courseSchedule,
    required this.courseColorData,
    this.cardHeight,
    this.onTap,
  });
  final CourseSchedule courseSchedule;
  final Map courseColorData;
  final double? cardHeight;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    double? _cardHeight = cardHeight;
    _cardHeight ??= context.select<CourseCardSettingsProvider, double>(
        (courseCardSettingsProvider) => courseCardSettingsProvider.cardHeight);

    double cardBorderRadius =
        context.select<CourseCardSettingsProvider, double>(
            (courseCardSettingsProvider) =>
                courseCardSettingsProvider.cardBorderRadius);
    double cardMargin = context.select<CourseCardSettingsProvider, double>(
        (courseCardSettingsProvider) => courseCardSettingsProvider.cardMargin);
    return SizedBox(
      width: double.infinity,
      height: _cardHeight * (courseSchedule.length ?? 2),
      child: Card(
        clipBehavior: Clip.hardEdge,
        // Card 在 Container 里的边距（在整体上表现为各个卡片间的间隙、间距）
        margin: EdgeInsets.all(cardMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        color: (courseColorData[courseSchedule.title]).toString().toColor() ??
            Colors.green.shade400,
        child: InkWell(
          onTap: () {
            var onTapFunc = onTap;
            if (onTapFunc != null) {
              onTapFunc(true);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 课程名称
                  CourseCardItem(
                    text: courseSchedule.title ?? '',
                    coursecardcategory: CourseItemCategory.title,
                  ),

                  // 上课地点
                  CourseCardItem(
                    text: courseSchedule.place ?? '',
                    coursecardcategory: CourseItemCategory.place,
                  ),

                  // 授课教师
                  CourseCardItem(
                    text: courseSchedule.instructor ?? '',
                    coursecardcategory: CourseItemCategory.instructor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
