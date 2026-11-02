import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/services/zhengfang_jwxt/class_schedule/parse_class_schedule.dart';
import 'package:sachet/utils/transform.dart';

import 'models/experiment_course.dart';

/// 解析实验课返回一个实验课程列表
Future<List<List<CourseSchedule>>> parseExperimentCourse(Map jsonData) async {
  final List<ExperimentCourse> responseExperimentCoursesList =
      parseResponseJsonToExperimentCourse(jsonData);
  List<List<CourseSchedule>> scheduleList = List.generate(35, (_) => []);

  for (final course in responseExperimentCoursesList) {
    ExperimentCourseParserZF.parseWithRegex(course, scheduleList);
  }

  return scheduleList;
}

/// 解析实验课并与原有的课程列表合并
///
/// 返回合并进课程表的实验课节次数，没有实验课时返回 0
Future<int> parseExperimentCourseMergeExistList(
    Map jsonData, List<List<CourseSchedule>> list) async {
  final List<ExperimentCourse> responseExperimentCoursesList =
      parseResponseJsonToExperimentCourse(jsonData);

  // 先解析到独立的列表，全部解析成功后再合并，
  // 避免中途解析失败时原课程表里留下不完整的实验课数据
  final List<List<CourseSchedule>> experimentScheduleList =
      List.generate(list.length, (_) => []);
  for (final course in responseExperimentCoursesList) {
    ExperimentCourseParserZF.parseWithRegex(course, experimentScheduleList);
  }

  int experimentCourseCount = 0;
  for (int i = 0; i < list.length; i++) {
    experimentCourseCount += experimentScheduleList[i].length;
    list[i].addAll(experimentScheduleList[i]);
  }

  return experimentCourseCount;
}

/// 把实验课表数据解析为 [ExperimentCourse] 列表
///
/// 没有查询到实验课表时返回空列表
List<ExperimentCourse> parseResponseJsonToExperimentCourse(Map dataJson) {
  final items = dataJson['items'];
  if (items is! List || items.isEmpty) {
    return [];
  }

  List<ExperimentCourse> experimentCourseList = [];
  for (final e in items) {
    ExperimentCourse experimentCourse = ExperimentCourse.fromJson(e);

    experimentCourseList.add(experimentCourse);
  }

  return experimentCourseList;
}

class ExperimentCourseParserZF {
  /*
  /// 使用 split，容易理解，但较死板。还有个可能发生的 bug: 如果地点包含空格会提前截断使地点在空格被切开导致地点不完整(虽然目前没见过地点中含空格的)
  static void parseWithSplit(
    ExperimentCourse course,
    List<List<CourseSchedule>> scheduleList,
  ) {
    // timeAndPlacesStr 数据示例：
    // "星期二 [5-6节 2周,11周] 机械楼101-焊接机器人实验室 ,星期一 [3-8节 11周] 机械楼101-焊接机器人实验室 "
    // "星期二 [5-6节 7周] 焊接楼115-焊接操作室Ⅰ ,星期四 [7-8节 7周] 焊接楼115-焊接操作室Ⅰ ,星期五 [5-6节 7周] 焊接楼115-焊接操作室Ⅰ ,星期一 [5-6节 7周] 焊接楼115-焊接操作室Ⅰ "
    // "星期一 [3-4节,7-8节 8周] 焊接楼111-备料室 "
    final String timeAndPlacesStr = course.sksjdd.toString();
    // final int counts = timeAndPlacesStr.split('星期').length - 1;

    // timeAndPlaces 数据示例：
    // ["星期二 [5-6节 2周,11周] 机械楼101-焊接机器人实验室", "星期一 [3-8节 11周] 机械楼101-焊接机器人实验室 "]
    final List<String> timeAndPlaces = timeAndPlacesStr.split(' ,');

    // timeAndPlace 数据示例：
    // "星期二 [5-6节 2周,11周] 机械楼101-焊接机器人实验室"
    // "星期一 [3-8节 11周] 机械楼101-焊接机器人实验室 "
    for (final timeAndPlace in timeAndPlaces) {
      // parts 数据示例：
      // ["星期二", "[5-6节", "2周,11周]", "机械楼101-焊接机器人实验室"]
      // ["星期一", "[3-8节", "11周]", "机械楼101-焊接机器人实验室 "]
      final parts = timeAndPlace.split(' ');

      // xingQiJi 数据示例：
      // "星期二"
      // "星期一"
      final xingQiJi = parts[0];

      // sessions 数据示例：
      // "5-6节"
      // "3-4节,7-8节"
      final sessions = parts[1].replaceFirst('[', '');

      // sessionsParts 数据示例：
      // ["5-6节"]
      // ["3-4节", "7-8节"]
      final sessionsParts = sessions.split(',');

      for (final sessionStr in sessionsParts) {
        // weeksStr 数据示例：
        // "2周,11周"
        // "11周"
        final weeksStr = parts[2].replaceFirst(']', '');

        // place 数据示例：
        // "机械楼101-焊接机器人实验室"
        // "焊接楼115-焊接操作室Ⅰ"
        final place = parts[3].trim();

        final weekdayIndex = xingQiJiToWeekday[xingQiJi];
        final weeks = ClassScheduleDataParserZF.parseWeeks(weeksStr);
        final startSession =
            ClassScheduleDataParserZF.parseStartSession(sessionStr);
        final sessionLength =
            ClassScheduleDataParserZF.parseSessionLength(sessionStr);

        final int itemIndex = ClassScheduleDataParserZF.parseItemIndex(
            "$weekdayIndex", "$startSession");
        CourseSchedule courseSchedule = CourseSchedule(
          item: itemIndex,
          title: course.kcmc,
          instructor: course.jsxm,
          place: place,
          length: sessionLength,
          weeks: weeks,
          isExperimentCourse: true,
          experimentName: course.xmmc,
          experimentGroupName: course.syfzmc,
        );
        scheduleList[itemIndex].add(courseSchedule);
      }
    }
  }
  */

  /// 使用正则
  static void parseWithRegex(
    ExperimentCourse course,
    List<List<CourseSchedule>> scheduleList,
  ) {
    // timeAndPlacesStr 数据示例：
    // "星期二 [5-6节 2周,11周] 机械楼101-焊接机器人实验室 ,星期一 [3-8节 11周] 机械楼101-焊接机器人实验室 "
    // "星期二 [5-6节 7周] 焊接楼115-焊接操作室Ⅰ ,星期四 [7-8节 7周] 焊接楼115-焊接操作室Ⅰ ,星期五 [5-6节 7周] 焊接楼115-焊接操作室Ⅰ ,星期一 [5-6节 7周] 焊接楼115-焊接操作室Ⅰ "
    // "星期一 [3-4节,7-8节 8周] 焊接楼111-备料室 "
    final String? timeAndPlacesStr = course.sksjdd;

    if (timeAndPlacesStr == null) {
      throw '上课时间和地点为 null';
    }

    // "星期X [节次 周次] 地点"
    final entryPattern = RegExp(
      r'星期\s*([一二三四五六七日天])\s*\[([^\]]*)\]\s*([\s\S]*?)'
      r'(?=\s*星期\s*[一二三四五六七日天]\s*\[|\s*$)',
    );

    final matches = entryPattern.allMatches(timeAndPlacesStr).toList();
    if (matches.isEmpty) {
      throw '正则匹配失败: $timeAndPlacesStr';
    }

    for (final match in matches) {
      final String xingQiJi = '星期${match.group(1)}';
      final String sessionsAndWeeks = match.group(2)!.trim();
      final String place = match
          .group(3)!
          .trim()
          .replaceFirst(RegExp(r'\s*[,，]\s*$'), '')
          .trim();

      if (sessionsAndWeeks.isEmpty) {
        throw '缺少节次和周次: "${match.group(0)}"';
      }

      final int? weekdayIndex = xingQiJiToWeekday[xingQiJi];
      if (weekdayIndex == null) {
        throw '星期几解析失败: $xingQiJi';
      }

      // 将 逗号+一个或多个空白变成纯逗号
      // 例如 "3-4节, 7-8节 8周" -> "3-4节,7-8节 8周"
      // (虽然目前没见过这种情况)
      final String normalized =
          sessionsAndWeeks.replaceAll(RegExp(r',\s+'), ',');
      final List<String> parts = normalized.split(' ');

      final String sessionsStr = parts[0];
      final String weeksStr = parts[1];

      final List<int> weeks = ClassScheduleDataParserZF.parseWeeks(weeksStr);

      for (final session in sessionsStr.split(',')) {
        int? startSession =
            ClassScheduleDataParserZF.parseStartSession(session);
        int sessionLength =
            ClassScheduleDataParserZF.parseSessionLength(session);
        if (startSession == null) {
          throw '节次解析失败 "$session": $timeAndPlacesStr';
        }

        final int itemIndex = ClassScheduleDataParserZF.parseItemIndex(
            '$weekdayIndex', '$startSession');

        scheduleList[itemIndex].add(CourseSchedule(
          item: itemIndex,
          title: course.kcmc,
          instructor: course.jsxm,
          place: place,
          length: sessionLength,
          weeks: weeks,
          isExperimentCourse: true,
          experimentName: course.xmmc,
          experimentGroupName: course.syfzmc,
        ));
      }
    }
  }

  /// 获取实验课所属课程名称列表
  static List<String> parseExperimentCourseTitleList(Map jsonData) {
    final items = jsonData['items'];
    if (items is! List) {
      return [];
    }

    Set<String> titles = {}; // 防止重复
    for (final e in items) {
      final title = e['kcmc'];
      titles.add(title);
    }
    final result = titles.toList();

    return result;
  }
}
