import 'package:sachet/models/course_schedule.dart';

Future parseClassScheduleZF(Map jsonData) async {
  List courseLength = jsonData['kbList'];
  if (courseLength.isEmpty) {
    throw '课表数据为空';
  }

  List<List<CourseSchedule>> scheduleList = List.generate(35, (_) => []);
  for (var e in jsonData['kbList']) {
    final xqj = e['xqj']; // 星期几
    final zcd = e['zcd']; // 周次
    final title = e['kcmc']; // 课程名称
    final instructor = e['xm']; // 授课教师
    final place = e['cdmc']; // 上课地点
    final jc = e['jc']; // 节次

    int item = ClassScheduleDataParserZF.parseItemIndex(xqj, jc);
    int length = ClassScheduleDataParserZF.parseSessionLength(jc);
    List weeks = ClassScheduleDataParserZF.parseWeeks(zcd);
    CourseSchedule courseSchedule = CourseSchedule(
      item: item,
      title: title,
      instructor: instructor,
      place: place,
      length: length,
      weeks: weeks,
    );
    scheduleList[item].add(courseSchedule);
  }
  return scheduleList;
}

class ClassScheduleDataParserZF {
  /// 提取周次为 List\<int>
  ///
  /// e.g.
  ///
  /// "8-12周" -> [8, 9, 10, 11, 12]
  ///
  /// "2-4周,6-11周" -> [2, 3, 4, 6, 7, 8, 9, 10, 11]
  static List<int> parseWeeks(String input) {
    // 移除所有“周”字和空格
    final cleaned = input.replaceAll(RegExp(r'周|\s'), '');

    // 分割逗号，得到每个范围
    final ranges = cleaned.split(',');

    final Set<int> weeks = {}; // 使用 Set 避免重复

    for (final range in ranges) {
      if (range.isEmpty) continue;

      final parts = range.split('-');
      if (parts.length == 1) {
        // 单个周，如 "5"
        final week = int.tryParse(parts[0]);
        if (week != null) {
          weeks.add(week);
        } else {
          throw '解析周次失败: $input';
        }
      } else if (parts.length == 2) {
        // 范围，如 "2-4"
        final start = int.tryParse(parts[0]);
        final end = int.tryParse(parts[1]);

        if (start != null && end != null && start <= end) {
          for (int i = start; i <= end; i++) {
            weeks.add(i);
          }
        } else {
          throw '解析周次失败: $input';
        }
      } else {
        throw '解析周次失败: $input';
      }
    }

    // 转为 List 并排序
    final result = weeks.toList()..sort();
    return result;
  }

  /// 提取节次的开始节次
  ///
  /// e.g.
  ///
  /// "1-2节" -> 1
  ///
  /// "3-4节" -> 3
  static int? parseStartSession(String input) {
    // 移除所有“节”字和空格
    final cleaned = input.replaceAll(RegExp(r'节|\s'), '');

    // 分割逗号，得到每个范围
    final ranges = cleaned.split('-');

    int? startSession = int.tryParse(ranges[0]);

    return startSession;
  }

  /// 从 jc(节次) 提取课程长度（节次数）
  ///
  /// e.g.
  ///
  /// "1-2节" -> 2
  ///
  /// "3-4节" -> 2
  static int parseSessionLength(String input) {
    // 移除所有“节”字和空格
    final cleaned = input.replaceAll(RegExp(r'节|\s'), '');

    // 分割逗号，得到每个范围
    // 如: 1-2节
    final ranges = cleaned.split('-');
    int? length;
    if (ranges.length == 2) {
      int? startSession = int.tryParse(ranges[0]);
      int? endSession = int.tryParse(ranges[1]);
      if (startSession == null || endSession == null) {
        throw '解析课程长度失败: $input';
      }
      length = endSession - startSession + 1;
    }
    // TODO: 不确定如果一节课只有一（小）节是什么数据。大多是2节，也有3节4节的。
    // 这里猜测可能是 "1节"，如果是 "1-1节"，那么上面也能成功解析。
    else if (ranges.length == 1) {
      length = 1;
    }
    if (length == null) {
      throw '解析课程长度失败: $input';
    }
    return length;
  }

  /// 从 xqj(星期几) 和 jc(节次) 得到 item
  ///
  /// item:
  ///
  ///       Mon Tue Wed Thu Fri Sat Sun
  /// 12      0   5  10  15  20  25  30
  /// 34      1   6  11  16  21  26  31
  /// 56      2   7  12  17  22  27  32
  /// 78      3   8  13  18  23  28  33
  /// 91011   4   9  14  19  24  29  34
  static int parseItemIndex(String weekDayInput, String sessionInput) {
    int? weekDay = int.tryParse(weekDayInput);
    if (weekDay == null) {
      throw '解析星期几失败: $weekDayInput';
    }
    if (weekDay < 1 || weekDay > 7) {
      throw '星期几超出范围: $weekDayInput';
    }
    int? startSession = parseStartSession(sessionInput);
    if (startSession == null) {
      throw '解析开始节次失败: $sessionInput';
    }
    int? startItem = startSessionToStartItem[startSession];
    if (startItem == null) {
      throw '解析 item 失败: $sessionInput';
    }

    int item = (weekDay - 1) * 5 + startItem - 1;

    return item;
  }

  /// 获取课程名称列表
  static List<String> parseCourseTitleList(Map jsonData) {
    Set<String> titles = {}; // 防止重复

    for (var e in jsonData['kbList']) {
      final title = e['kcmc'];
      titles.add(title);
    }
    final result = titles.toList();

    return result;
  }

  /// 获取学期 e.g. "2025-2026-1"
  static String parseSemester(Map jsonData) {
    var result = '${jsonData['xsxx']['XNMC']}-${jsonData['xsxx']['XQMMC']}';
    return result;
  }
}

const Map<int, int> startSessionToStartItem = {
  1: 1,
  3: 2,
  5: 3,
  7: 4,
  9: 5,
};
