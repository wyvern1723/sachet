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

// 从周数和 weekDay 得到那一天的日期
DateTime getDate(DateTime semesterStartDate, int weekCount, int weekDay) {
  final date = semesterStartDate
      .add(Duration(days: (weekCount - 1) * DateTime.daysPerWeek + weekDay));
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
