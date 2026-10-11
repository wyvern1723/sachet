import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/course_info_helper.dart';
import 'package:sachet/utils/utils_functions.dart';
import 'package:sachet/widgets/classpage_widgets/course_details_bottom_sheet.dart';
import 'package:sachet/widgets/classpage_widgets/stripe_band_banner.dart';
import 'package:sachet/widgets/settingspage_widgets/customize_settings_widgets/set_course_card_appearance.dart';
import 'package:provider/provider.dart';

import '../../utils/transform.dart';
import 'course_card_item.dart';

enum CourseCardVariant { normal, compact }

class CourseCard extends StatelessWidget {
  final double cardHeight;
  final double? cardBorderRadius;
  final int weekCount;
  final int weekday;
  final int classCount; // classCount 节次（ 1~5 ）
  final List<CourseSchedule> courseScheduleItems;
  final Map? courseColorData;
  final CourseCardVariant variant;

  const CourseCard({
    super.key,
    required this.cardHeight,
    required this.weekCount,
    required this.weekday,
    required this.classCount,
    required this.courseScheduleItems,
    required this.courseColorData,
    this.cardBorderRadius,
    this.variant = CourseCardVariant.normal,
  });

  const CourseCard.compact({
    super.key,
    required this.cardHeight,
    required this.weekCount,
    required this.weekday,
    required this.classCount,
    required this.courseScheduleItems,
    required this.courseColorData,
    this.cardBorderRadius,
  }) : variant = CourseCardVariant.compact;

  void _showCourseDetails({
    required BuildContext context,
    required String courseTitle,
    required int weekday,
    required int classcount,
    bool isStaggered = false, // 用户点击的课程的此节是否错峰上课
    required int currentCourseLength, // 用户点击的课程的此节的持续节数
  }) {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext context) {
        final List weeks = CourseInfoHelper.getWeeksOfCourse(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        final List<int> lengths = CourseInfoHelper.getLengths(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        final List instructors = CourseInfoHelper.getInstructors(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        final List places = CourseInfoHelper.getPlaces(
          title: courseTitle,
          courseScheduleItems: courseScheduleItems,
        );
        final List sectionsShowText = [];

        String? staggeredTime;

        for (final length in lengths) {
          final int startSession = classCountToSection[classcount]!;
          final int endSession = classCountToSection[classcount]! + length - 1;
          sectionsShowText.add('$startSession~$endSession节次');

          if (length == currentCourseLength && isStaggered) {
            List<String> times = [];

            for (int i = startSession; i <= endSession; i++) {
              final String startTime =
                  classSessionWinterRoutineStaggeredStartTime[i - 1];
              final String endTime =
                  classSessionWinterRoutineStaggeredEndTime[i - 1];
              times.add('第$i节: $startTime-$endTime');
            }

            staggeredTime = times.join('\n');
          }
        }

        return CourseDetailsBottomSheet(
          courseTitle: courseTitle,
          weekday: weekday,
          weeks: weeks,
          lengths: lengths,
          instructors: instructors,
          places: places,
          sectionsShowText: sectionsShowText,
          staggeredTime: staggeredTime,
        );
      },
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

      String classScheduleFilePath = context.select<SettingsProvider, String>(
          (provider) => provider.classScheduleFilePath);
      final String semester = extractSemester(classScheduleFilePath);

      final String coursePlace = courseSchedule.place ?? '';

      /// 这节课是否延迟10分钟上课（逸夫楼或信息科技大楼的课）
      /// 通知说「自 2026年10月1日（周四）起，试行错峰上课」
      /// 但国庆放假不上课，所以实际从 2026年10月8日（周四），才有课程实行错峰上课，此时为 2026-2027 学年 第 1 学期的第 5 周
      /// 本学期的第1周-第4周，上课时间是没有错峰的，所以不标记第5周前错峰上课的课程。
      /// [关于试行错峰上课的通知-政务信息港](https://zwxxg.xtu.edu.cn/content.jsp?urltype=news.NewsContentUrl&wbtreeid=1066&wbnewsid=10705)

      /// 这节课的上课地点是否属于需要错峰上课（延迟上课时间）的教学楼
      final bool isStaggeredPlace =
          (coursePlace.contains('逸夫楼') || coursePlace.contains('信息科技大楼'));

      /// 这节课的日期是否还在试行错峰上课方案的开始日期之前
      final bool isBeforeStaggeredStartDate =
          (semester == '2026-2027-1' && weekCount < 5);

      /// 这节课是否错峰上课（延迟上课时间）
      final bool isStaggered = isStaggeredPlace && !isBeforeStaggeredStartDate;

      switch (variant) {
        case CourseCardVariant.normal:
          return CourseCardNormal(
              weekCount: weekCount,
              courseColorData: courseColorData,
              courseSchedule: courseSchedule,
              cardHeight: cardHeight,
              cardBorderRadius: cardBorderRadius,
              isStaggered: isStaggered,
              onTap: (_) {
                _showCourseDetails(
                  context: context,
                  courseTitle: courseSchedule.title ?? '',
                  weekday: weekday,
                  classcount: classCount,
                  isStaggered: isStaggered,
                  currentCourseLength: courseSchedule.length ?? 2,
                );
              });
        case CourseCardVariant.compact:
          return CourseCardCompact(
              courseColorData: courseColorData,
              courseSchedule: courseSchedule,
              cardHeight: cardHeight,
              cardBorderRadius: cardBorderRadius,
              onTap: (_) {
                _showCourseDetails(
                  context: context,
                  courseTitle: courseSchedule.title ?? '',
                  weekday: weekday,
                  classcount: classCount,
                  isStaggered: isStaggered,
                  currentCourseLength: courseSchedule.length ?? 2,
                );
              });
      }
    }
  }
}

class CourseCardNormal extends StatelessWidget {
  const CourseCardNormal({
    super.key,
    required this.weekCount,
    required this.courseSchedule,
    required this.courseColorData,
    this.cardHeight,
    this.cardBorderRadius,
    this.isStaggered = false,
    this.onTap,
  });
  final int weekCount;
  final CourseSchedule courseSchedule;
  final Map? courseColorData;
  final double? cardHeight;
  final double? cardBorderRadius;
  final bool isStaggered;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    double? _cardHeight = cardHeight;
    _cardHeight ??= context.select<CourseCardSettingsProvider, double>(
        (courseCardSettingsProvider) => courseCardSettingsProvider.cardHeight);

    // ignore: no_leading_underscores_for_local_identifiers
    double _cardBorderRadius = cardBorderRadius ??
        context.select<CourseCardSettingsProvider, double>(
            (courseCardSettingsProvider) =>
                courseCardSettingsProvider.cardBorderRadius);
    double cardMargin = context.select<CourseCardSettingsProvider, double>(
        (courseCardSettingsProvider) => courseCardSettingsProvider.cardMargin);

    return Stack(
      children: [
        if (isStaggered)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: StripeBandBanner(
              label: '错峰 +10\u2006min',
              padding: EdgeInsets.fromLTRB(6, 0, 2, 0),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_cardBorderRadius)),
              margin: EdgeInsets.all(cardMargin),
              textHeight: 0.1 * _cardHeight,
            ),
          ),
        Transform.translate(
          offset: Offset(
            0,
            isStaggered ? 0.1 * _cardHeight : 0,
          ),
          child: SizedBox(
            width: double.infinity,
            height: isStaggered
                ? _cardHeight * (courseSchedule.length ?? 2) -
                    _cardHeight * 0.05
                : _cardHeight * (courseSchedule.length ?? 2),
            child: Card(
              clipBehavior: Clip.hardEdge,
              // Card 在 SizedBox 里的边距（在整体上表现为各个卡片间的间隙/间距）
              margin: EdgeInsets.all(cardMargin),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_cardBorderRadius),
              ),
              color: (courseColorData?[courseSchedule.title])
                      .toString()
                      .toColor() ??
                  Colors.green.shade400,
              child: InkWell(
                onTap: () {
                  var onTapFunc = onTap;
                  if (onTapFunc != null) {
                    onTapFunc(true);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 2.0),
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
          ),
        ),
      ],
    );
  }
}

class CourseCardCompact extends StatelessWidget {
  const CourseCardCompact({
    super.key,
    required this.courseSchedule,
    required this.courseColorData,
    this.cardHeight,
    this.cardBorderRadius,
    this.onTap,
  });
  final CourseSchedule courseSchedule;
  final Map? courseColorData;
  final double? cardHeight;
  final double? cardBorderRadius;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final double _cardHeight = cardHeight ?? 10;
    final courseCardSettings = context.watch<CourseCardSettingsProvider>();

    // ignore: no_leading_underscores_for_local_identifiers
    final double _cardBorderRadius = cardBorderRadius ??
        context.select<CourseCardSettingsProvider, double>(
            (courseCardSettingsProvider) =>
                courseCardSettingsProvider.cardBorderRadius);
    double cardMargin = 1.0;
    return SizedBox(
      width: double.infinity,
      height: _cardHeight * (courseSchedule.length ?? 2),
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.all(cardMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        color: (courseColorData?[courseSchedule.title]).toString().toColor() ??
            Colors.green.shade400,
        child: InkWell(
          onTap: () {
            final onTapFunc = onTap;
            if (onTapFunc != null) {
              onTapFunc(true);
            }
          },
          child: Builder(builder: (context) {
            final maxLines = (_cardHeight * (courseSchedule.length ?? 2) / 11)
                .floor()
                .clamp(1, 100);
            return Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 2.0 : 0.0),
              child: Text(
                courseSchedule.title ?? '',
                style: TextStyle(
                  fontWeight:
                      intToFontWeight(courseCardSettings.titleFontWeight),
                  fontSize: 10,
                  color: colorFromHex(courseCardSettings.titleTextColor),
                ),
                textAlign: TextAlign.center,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ),
    );
  }
}
