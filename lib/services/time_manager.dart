// 管理时间

// 从周数推这一周第一天时间
// 第 n 周的第一天（周一） = 学期第一周的第一天 + (n-1) * 7
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
