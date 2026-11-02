import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/models/session_routine.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/course_info_helper.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/widgets/classpage_widgets/course_details_bottom_sheet.dart';
import 'package:sachet/widgets/classpage_widgets/stripe_band_banner.dart';
import 'package:sachet/widgets/settingspage_widgets/customize_settings_widgets/set_course_card_appearance.dart';
import 'package:provider/provider.dart';

import '../../utils/transform.dart';
import 'course_card_item.dart';

enum CourseCardVariant { normal, compact }

class CourseCard extends StatelessWidget {
  final int weekCount;
  final int weekday;
  final int classCount; // classCount 节次（ 1~5 ）
  final List<CourseSchedule> courseScheduleItems;
  final Map? courseColorData;
  final double cardHeight;
  final double? cardBorderRadius;
  final CourseCardVariant variant;

  const CourseCard({
    super.key,
    required this.weekCount,
    required this.weekday,
    required this.classCount,
    required this.courseScheduleItems,
    required this.courseColorData,
    required this.cardHeight,
    this.cardBorderRadius,
    this.variant = CourseCardVariant.normal,
  });

  const CourseCard.compact({
    super.key,
    required this.weekCount,
    required this.weekday,
    required this.classCount,
    required this.courseScheduleItems,
    required this.courseColorData,
    required this.cardHeight,
    this.cardBorderRadius,
  }) : variant = CourseCardVariant.compact;

  void _showCourseDetails({
    required BuildContext context,
    required DateTime date,
    required String courseTitle,
    required int weekday,
    required int classcount,
    bool isStaggered = false, // 用户点击的课程的此节是否错峰上课
    required int currentCourseLength, // 用户点击的课程的此节的持续节数
    bool? isExperimentCourse,
    String? experimentName,
    String? experimentGroupName,
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
          isExperimentCourse: isExperimentCourse,
          courseScheduleItems: courseScheduleItems,
        );
        final List<int> lengths = CourseInfoHelper.getLengths(
          title: courseTitle,
          isExperimentCourse: isExperimentCourse,
          courseScheduleItems: courseScheduleItems,
        );
        final List instructors = CourseInfoHelper.getInstructors(
          title: courseTitle,
          isExperimentCourse: isExperimentCourse,
          courseScheduleItems: courseScheduleItems,
        );
        final List places = CourseInfoHelper.getPlaces(
          title: courseTitle,
          isExperimentCourse: isExperimentCourse,
          courseScheduleItems: courseScheduleItems,
        );
        final List sectionsShowText = [];

        /// 显示的此课内每小节的开始和结束时间
        /// 如果此节课的持续时间在不同周不同(例如在第2-8周，上课时间是 9-11 节，但在第9周，上课时间变成了 9-10 节)，
        /// 则只显示当前点击的这节课在所属周下每小节的开始和结束时间
        String? timeShowText;

        for (final length in lengths) {
          final int startSession = classCountToSection[classcount]!;
          final int endSession = classCountToSection[classcount]! + length - 1;
          sectionsShowText.add('$startSession~$endSession节次');

          if (length == currentCourseLength) {
            List<String> times = [];

            for (int i = startSession; i <= endSession; i++) {
              final period =
                  SessionRoutine(date: date, isStaggered: isStaggered)
                      .periods[i - 1];
              final String startTime = period.startTime;
              final String endTime = period.endTime;
              times.add('第$i节: $startTime-$endTime');
            }

            timeShowText = times.join('\n');
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
          time: timeShowText,
          isStaggered: isStaggered,
          isExperimentCourse: isExperimentCourse,
          experimentName: experimentName,
          experimentGroupName: experimentGroupName,
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

      final String coursePlace = courseSchedule.place ?? '';

      /// 这节课的上课地点是否属于需要错峰上课（延迟上课时间）的教学楼
      final bool isStaggeredPlace =
          SessionRoutine.isStaggeredPlace(coursePlace);

      /// 这节课所属天的日期
      final DateTime date = getDateFromWeekCountAndWeekday(
        semesterStartDate: SettingsProvider.semesterStartDateDateTime,
        weekCount: weekCount,
        weekday: weekday,
      );

      /// 这节课的日期是否还在试行错峰上课方案的开始日期之前
      final bool isBeforeStaggeredStartDate =
          SessionRoutine.isBeforeStaggeredStartDate(date);

      final bool isSummer = SessionRoutine.isSummer(date);

      // TODO: 目前不确定下一学期(2026-2027学年 第2学期)是否会采用错峰上课同时也不确定夏季作息的错峰上课时间表。在夏季作息的错峰上课时间表公布前，当前逻辑是只在当前及之后学期的冬季作息才将需要错峰的课程标注为错峰上课
      /// 这节课是否错峰上课（延迟上课时间）
      final bool isStaggered =
          isStaggeredPlace && !isBeforeStaggeredStartDate && !isSummer;

      switch (variant) {
        case CourseCardVariant.normal:
          return CourseCardNormal(
              weekCount: weekCount,
              classCount: classCount,
              courseColorData: courseColorData,
              courseSchedule: courseSchedule,
              cardHeight: cardHeight,
              cardBorderRadius: cardBorderRadius,
              isStaggered: isStaggered,
              onTap: (_) {
                _showCourseDetails(
                  context: context,
                  date: date,
                  courseTitle: courseSchedule.title ?? '',
                  weekday: weekday,
                  classcount: classCount,
                  isStaggered: isStaggered,
                  currentCourseLength: courseSchedule.length ?? 2,
                  isExperimentCourse: courseSchedule.isExperimentCourse,
                  experimentName: courseSchedule.experimentName,
                  experimentGroupName: courseSchedule.experimentGroupName,
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
                  date: date,
                  courseTitle: courseSchedule.title ?? '',
                  weekday: weekday,
                  classcount: classCount,
                  isStaggered: isStaggered,
                  currentCourseLength: courseSchedule.length ?? 2,
                  isExperimentCourse: courseSchedule.isExperimentCourse,
                  experimentName: courseSchedule.experimentName,
                  experimentGroupName: courseSchedule.experimentGroupName,
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
    required this.classCount,
    required this.courseSchedule,
    required this.courseColorData,
    this.cardHeight,
    this.cardBorderRadius,
    this.isStaggered = false,
    this.onTap,
  });
  final int weekCount;
  final int classCount;
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

    final int courseLength = courseSchedule.length ?? 2;

    /// 这节课的开始节次
    final int startSession = classCount + 1;

    /// 这节课的结束节次
    final int endSession = startSession + courseLength - 1;

    /// 这节课穿过了几次大的课间休息段（大课间(第2节课和第3节课中间,第6节课和第7节课中间)及午间休息(第4节课和第5节课中间)及晚间休息(第8节课和第9节课中间)）
    final int n = const [2, 4, 6, 8]
        .where((b) => startSession < b && b < endSession)
        .length;

    /// 课程原始高度
    final double originHeight = _cardHeight * courseLength;

    /// 课程中穿过大的课间休息段的高度
    final double breakHeight = _cardHeight * n * 0.05;

    /// 此课程卡片总高度
    final double height = originHeight + breakHeight;

    /// 错峰上课（延迟上课）的课程卡片顶部从上到下位移的高度
    final double staggeredOffset = 0.1 * _cardHeight;

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
            isStaggered ? staggeredOffset : 0,
          ),
          child: SizedBox(
            width: double.infinity,
            height: isStaggered
                // 如果是错峰上课的课，在顶部会向下移 1 个 staggeredOffset 的位移
                // 如果课程卡片高度与时间成比例，底部也要下移同样的长度，因为课程时长不变，所以高度也应不变。
                // 但如果这样处理，不改变卡片高度，只是将课程卡片整体向下移动，
                // 延迟上课的上节课的底部可能会和正常上课的下节课的顶部有重叠（即使我们已在各课程间留了一定的空位(0.05 倍的 _cardHeight, 即 0.5 倍的 staggeredOffset)）
                // 如果再增加空白的高度可以解决这个问题，但是增加空白过多会导致课程整体 UI 太分散，当前留白应为较合适的高度
                // 所以只是为了在视觉上使错峰上课的课比正常上课的课结束更晚，只要适当地延长卡片底部，就看起来比其他课结束晚了。
                // 过度追求课程卡片高度和时间的对应关系只会让眼睛如同游标卡尺的用户更舒服，反正绝大部分用户看不出来这微小的差距
                // 我们将课程卡片高度减去 0.5 * staggeredOffset（即顶部产生的向下的位移的一半），
                // 因为顶部向下位移 1 * staggeredOffset，而卡片高度减去 0.5 * staggeredOffset，所以底部看起来向下位移 0.5 * staggeredOffset
                // 达到了上课更晚，下课更晚的视觉效果，而底部向下高度正好是课程间留白的高度（不包括 cardMargin, cardMargin 默认为 2，除非用户手动设为 0, 不然课程卡片是不会挤在一起的），又不会导致重叠的问题
                ? height - staggeredOffset * 0.5
                : height,
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
