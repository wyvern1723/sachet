import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/utils/transform.dart';

/// 一天中一门课程卡片的位置信息
class CourseCardLayout {
  CourseCardLayout({
    required this.courseSchedule,
    required this.classCount,
    required this.startSession,
    required this.endSession,
  });

  final CourseSchedule courseSchedule;
  final int classCount;
  final int startSession;
  final int endSession;

  /// 在重叠课程中所在的列
  int columnIndex = 0;

  /// 所属重叠组的总列数
  int columnCount = 1;
}

/// 计算某天所有课程卡片的列分配
///
/// 重叠课程分列显示；连续重叠的课程按同一组的总列数平分宽度。
List<CourseCardLayout> getDayCourseLayouts({
  required List<List<CourseSchedule>> courseScheduleItemsList,
  required int weekday,
  required int weekCount,
}) {
  assert(classCountToSection.length == classCountsPerDay);

  final int firstItem = getItemFromWeekdayAndClassCount(weekday, 0);
  final List<CourseCardLayout> courseLayouts = [];

  for (int classCount = 0; classCount < classCountsPerDay; classCount++) {
    final int startSession = classCountToSection[classCount]!;
    for (final courseSchedule
        in courseScheduleItemsList[firstItem + classCount]) {
      if (courseSchedule.title == null || courseSchedule.title == '') continue;
      if (!(courseSchedule.weeks?.contains(weekCount) ?? false)) continue;

      final int courseLength = courseSchedule.length ?? 2;
      courseLayouts.add(CourseCardLayout(
        courseSchedule: courseSchedule,
        classCount: classCount,
        startSession: startSession,
        endSession: startSession + courseLength - 1,
      ));
    }
  }

  // 同时开始的课程较长的在前，列分配更稳定
  courseLayouts.sort((a, b) => a.startSession == b.startSession
      ? b.endSession.compareTo(a.endSession)
      : a.startSession.compareTo(b.startSession));

  final List<int> columnEndSessions = [];
  int groupStart = 0;
  int groupEndSession = -1;
  int groupColumnCount = 1;

  // 组内卡片统一宽度，避免并发数不同时横向重叠。
  void applyGroupColumnCount(int end) {
    for (int i = groupStart; i < end; i++) {
      courseLayouts[i].columnCount = groupColumnCount;
    }
  }

  for (int i = 0; i < courseLayouts.length; i++) {
    final courseLayout = courseLayouts[i];

    // 放入第一个已经空出的列
    int columnIndex = columnEndSessions
        .indexWhere((endSession) => endSession < courseLayout.startSession);
    if (columnIndex == -1) {
      columnIndex = columnEndSessions.length;
      columnEndSessions.add(courseLayout.endSession);
    } else {
      columnEndSessions[columnIndex] = courseLayout.endSession;
    }
    courseLayout.columnIndex = columnIndex;

    if (courseLayout.startSession > groupEndSession) {
      // 与上一组没有重叠，结算上一组
      applyGroupColumnCount(i);
      groupStart = i;
      groupEndSession = courseLayout.endSession;
      groupColumnCount = columnIndex + 1;
    } else {
      if (courseLayout.endSession > groupEndSession) {
        groupEndSession = courseLayout.endSession;
      }
      if (columnIndex + 1 > groupColumnCount) {
        groupColumnCount = columnIndex + 1;
      }
    }
  }
  applyGroupColumnCount(courseLayouts.length);

  return courseLayouts;
}
