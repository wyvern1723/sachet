// 管理时间

// 从周数推这一周第一天时间
// 第 n 周的第一天（周一） = 学期第一周的第一天 + (n-1) * 7
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/providers/settings_provider.dart';

DateTime getTheMondayDateOfTheWeek(DateTime semesterStartDate, int weekCount) {
  final weekMonday = semesterStartDate.add(Duration(
      days:
          (weekCount - 1) * DateTime.daysPerWeek)); // DateTime.daysPerWeek = 7
  return weekMonday;
}

// 得到今天的周次
int weekCountOfToday(DateTime semesterStartDate) {
  final now = DateTime.now();
  final difference = now.difference(semesterStartDate);
  final dWeek = (difference.inSeconds / Duration.secondsPerDay / 7).ceil();
  return dWeek;
}

/// 根据学期起始日和给定日期，计算给定日期的周次和星期几
///
/// - `semesterStartDate`: 学期开始日期
/// - `date`: 需要计算的日期
///
/// Returns: (String weekCount, DateTime weekday)
/// - `weekCount`: 周次(1-20)
/// - `weekday`: 星期几(1-7)
({int weekCount, int weekday}) getWeekCountAndWeekdayOfDate({
  required DateTime semesterStartDate,
  required DateTime date,
}) {
  final difference = date.difference(semesterStartDate);
  final int weekCount = (difference.inDays ~/ 7) + 1;
  final int weekday = date.weekday;
  return (weekCount: weekCount, weekday: weekday);
}

/// 根据学期起始日、周次和星期几，计算对应的具体日期
///
/// - `semesterStartDate`: 学期开始日期
/// - `weekCount`: 周次（第几周）（1-20）
/// - `weekday`: 星期几（1=星期一, 7=星期日，与 [DateTime.weekday] 一致）
DateTime getDateFromWeekCountAndWeekday({
  required DateTime semesterStartDate,
  required int weekCount,
  required int weekday,
}) {
  final date = semesterStartDate.add(
      Duration(days: (weekCount - 1) * DateTime.daysPerWeek + weekday - 1));
  return date;
}

bool isToday(DateTime thatDay) {
  DateTime today = DateTime.now();
  if (thatDay.year == today.year &&
      thatDay.month == today.month &&
      thatDay.day == today.day) {
    return true;
  } else {
    return false;
  }
}

/// 从 item 得到 weekday 和 开始 session
///
/// 如 0 => weekday: 1, session: 1
///
/// 如 1 => weekday: 1, session: 3
///
/// 如 17 => weekday: 4, session: 5
///
/// 如 23 => weekday: 5, session: 7
///
/// 如 34 => weekday: 7, session: 9
///
/// ```
/// item:
///
///       Mon Tue Wed Thu Fri Sat Sun
/// 12      0   5  10  15  20  25  30
/// 34      1   6  11  16  21  26  31
/// 56      2   7  12  17  22  27  32
/// 78      3   8  13  18  23  28  33
/// 91011   4   9  14  19  24  29  34
/// ```
({int weekday, int session}) getWeekdayAndSessionFromItem(int item) {
  final int session = [1, 3, 5, 7, 9][item % 5];
  return (weekday: (item ~/ 5) + 1, session: session);
}

/// 获取课程的开始和结束时间
({DateTime startTime, DateTime endTime}) getStartAndEndTime(
    {required int item, required int week, required int courseLength}) {
  final result = getWeekdayAndSessionFromItem(item);
  final int courseWeekday = result.weekday;

  // 课程开始节次，有 1/3/5/7/9
  final int courseStartSession = result.session;

  /// 这节课的日期（如 2025-09-08 00:00:00，日期精确，时间为0点）
  final DateTime courseDate = getDateFromWeekCountAndWeekday(
    semesterStartDate: DateTime.tryParse(SettingsProvider.semesterStartDate) ??
        constSemesterStartDate,
    weekCount: week,
    weekday: courseWeekday,
  );

  String courseStartTimeStr = '';
  String courseEndTimeStr = '';

  /// 是否是夏令时
  final bool isSummerRountine = courseDate.month > 4 && courseDate.month < 10;
  if (isSummerRountine) {
    courseStartTimeStr =
        classSessionSummerRoutineStartTime[courseStartSession - 1];
    courseEndTimeStr = classSessionSummerRoutineEndTime[
        courseStartSession - 1 + courseLength - 1];
  } else {
    courseStartTimeStr =
        classSessionWinterRoutineStartTime[courseStartSession - 1];
    courseEndTimeStr = classSessionWinterRoutineEndTime[
        courseStartSession - 1 + courseLength - 1];
  }

  /// 这节课的开始日期和时间（如 2025-09-08 08:00:00，日期精确，时间精确）
  final DateTime courseStartDateTime = courseDate.add(
    Duration(
      hours: int.parse(courseStartTimeStr.split(':')[0]),
      minutes: int.parse(courseStartTimeStr.split(':')[1]),
    ),
  );

  final DateTime courseEndDateTime = courseDate.add(
    Duration(
      hours: int.parse(courseEndTimeStr.split(':')[0]),
      minutes: int.parse(courseEndTimeStr.split(':')[1]),
    ),
  );
  return (startTime: courseStartDateTime, endTime: courseEndDateTime);
}

/// 从字符串得到 DateTime 类型的考试开始和结束时间
///
/// - dateStr 格式: "2025-11-20(16:30-18:30)"、"2025-11-27(16:30-18:30)"
({DateTime? startDateTime, DateTime? endDateTime}) extractExamDateTime(
    String dateStr) {
  RegExp datePattern = RegExp(
      r"(\d{4}-\d{2}-\d{2})\s*\(\s*(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})\s*\)");

  Match? match = datePattern.firstMatch(dateStr);
  if (match != null) {
    String datePart = match.group(1)!;
    String startTimePart = match.group(2)!;
    String endTimePart = match.group(3)!;
    DateTime? startDateTime = DateTime.tryParse("$datePart $startTimePart:00");
    DateTime? endDateTime = DateTime.tryParse("$datePart $endTimePart:00");
    return (startDateTime: startDateTime, endDateTime: endDateTime);
  }
  return (startDateTime: null, endDateTime: null);
}
