import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/models/exam_time_zf.dart';
import 'package:sachet/services/time_manager.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:uuid/uuid.dart';

/// 导出课程表数据到 .ics 文件
///
/// 参数:
/// - rawfilePath: 原始课程表数据路径(应用内部储存路径)
/// - savefileName: 保存文件名
///
/// return:
/// - 成功: String filePath 导出的 .ics 文件保存的位置
/// - 用户取消保存: null
/// - 课程信息为空/课程表格式错误: throw String msg
Future<String?> exportClassScheduleToIcs(
  String rawfilePath,
  String savefileName,
) async {
  List courseScheduleItemsList = [];

  final rawData = await CachedDataStorage().getDecodedData(
    path: rawfilePath,
    type: List,
  );

  if (rawData is List && rawData.isNotEmpty) {
    courseScheduleItemsList = rawData;
    if (courseScheduleItemsList.length != 35) {
      throw '课程表文件格式错误';
    }
  } else {
    throw '课程信息为空/课程表文件格式错误';
  }

  final String ics =
      generateIcsFromSchedule(courseScheduleItemsList: courseScheduleItemsList);

  final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '保存课程表日历文件到...',
      fileName: '$savefileName.ics',
      type: FileType.custom,
      allowedExtensions: ['ics'],
      bytes: utf8.encode(ics));

  if (filePath != null) {
    return filePath;
  } else {
    return null;
  }
}

/// 将课程表数据转换为 .ics 字符串
String generateIcsFromSchedule({
  required List courseScheduleItemsList,
  String prodId = '-//wyvern1723//Sachet//ZH',
  String domain = 'wyvernlab.com',
}) {
  final events = <String>[];
  final uuid = const Uuid();
  final now = DateTime.now().toUtc();

  for (var courseScheduleItems in courseScheduleItemsList) {
    for (var courseScheduleItem in courseScheduleItems) {
      CourseSchedule course = CourseSchedule.fromJson(courseScheduleItem);

      final int? courseItem = course.item;
      final String? courseTitle = course.title;
      final String courseInstructor = course.instructor ?? '';
      final String coursePlace = course.place ?? '';
      final List? courseWeeks = course.weeks;
      final int courseLength = course.length ?? 2;

      if (courseTitle == null ||
          courseTitle.isEmpty ||
          courseWeeks == null ||
          courseWeeks.isEmpty ||
          courseItem == null) {
        continue;
      }

      for (final week in courseWeeks) {
        final time = getStartAndEndTime(
          item: courseItem,
          week: week,
          courseLength: courseLength,
        );

        final String uid = '${uuid.v4()}@$domain';

        final String dtstamp = '${formatLocalDateTime(now)}Z';

        final String dtstart = formatLocalDateTime(time.startTime);
        final String dtend = formatLocalDateTime(time.endTime);

        final event = buildEvent(
          uid: uid,
          dtstamp: dtstamp,
          courseTitle: courseTitle,
          coursePlace: coursePlace,
          courseInstructor: courseInstructor,
          dtstart: dtstart,
          dtend: dtend,
        );
        events.add(event);
      }
    }
  }

  // 合并所有事件
  return '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:$prodId
CALSCALE:GREGORIAN

BEGIN:VTIMEZONE
TZID:Asia/Shanghai
X-LIC-LOCATION:Asia/Shanghai
BEGIN:STANDARD
TZOFFSETFROM:+0800
TZOFFSETTO:+0800
TZNAME:CST
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE

${events.join('\n')}

END:VCALENDAR
''';
}

/// 导出考试时间数据到 .ics 文件
///
/// 参数:
/// - exams
/// - savefileName: 保存文件名
///
/// return:
/// - 成功: String filePath 导出的 .ics 文件保存的位置
/// - 用户取消保存: null
/// - 考试信息格式错误/解析错误: throw String msg
Future<String?> exportExamTimeToIcs({
  required List<ExamTimeZF> exams,
  required String savefileName,
}) async {
  final String ics = generateIcsFromExamTime(exams: exams);

  final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '保存考试时间日历文件到...',
      fileName: '$savefileName.ics',
      type: FileType.custom,
      allowedExtensions: ['ics'],
      bytes: utf8.encode(ics));

  if (filePath != null) {
    return filePath;
  } else {
    return null;
  }
}

/// 将考试时间数据转换为 .ics 字符串
String generateIcsFromExamTime({
  required List<ExamTimeZF> exams,
  String prodId = '-//wyvern1723//Sachet//ZH',
  String domain = 'wyvernlab.com',
}) {
  final events = <String>[];
  final uuid = const Uuid();
  final now = DateTime.now().toUtc();

  for (var exam in exams) {
    final String examTitle = exam.courseTitle;
    final String examPlace = exam.place;
    final String examTime = exam.time;
    final String examInstructorInfo = exam.instructorInfo;

    final String uid = '${uuid.v4()}@$domain';

    final String dtstamp = '${formatLocalDateTime(now)}Z';

    final time = extractExamDateTime(examTime);
    final examStartTime = time.startDateTime;
    final examEndTime = time.endDateTime;

    if (examStartTime == null || examEndTime == null) {
      throw '解析考试时间失败： $examTime';
    }

    final String dtstart = formatLocalDateTime(examStartTime);
    final String dtend = formatLocalDateTime(examEndTime);

    final event = buildEvent(
      uid: uid,
      dtstamp: dtstamp,
      courseTitle: '$examTitle考试',
      coursePlace: examPlace,
      courseInstructor: examInstructorInfo,
      dtstart: dtstart,
      dtend: dtend,
      triggerTime: '-PT60M',
    );
    events.add(event);
  }

  // 合并所有事件
  return '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:$prodId
CALSCALE:GREGORIAN

BEGIN:VTIMEZONE
TZID:Asia/Shanghai
X-LIC-LOCATION:Asia/Shanghai
BEGIN:STANDARD
TZOFFSETFROM:+0800
TZOFFSETTO:+0800
TZNAME:CST
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE

${events.join('\n')}

END:VCALENDAR
''';
}

// ics 转义
String escapeIcsText(String input) {
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll(',', '\\,')
      .replaceAll(';', '\\;')
      .replaceAll('\r\n', '\\n')
      .replaceAll('\r', '\\n')
      .replaceAll('\n', '\\n');
}

String formatLocalDateTime(DateTime dt) {
  return '${dt.year}'
      '${dt.month.toString().padLeft(2, '0')}'
      '${dt.day.toString().padLeft(2, '0')}T'
      '${dt.hour.toString().padLeft(2, '0')}'
      '${dt.minute.toString().padLeft(2, '0')}'
      '${dt.second.toString().padLeft(2, '0')}';
}

String buildEvent({
  required String uid,
  required String dtstamp,
  required String courseTitle,
  required String coursePlace,
  required String courseInstructor,
  required String dtstart,
  required String dtend,
  String triggerTime = '-PT30M',
}) {
  final buffer = StringBuffer();

  buffer.writeln('BEGIN:VEVENT');
  buffer.writeln('UID:$uid');
  buffer.writeln('DTSTAMP:$dtstamp');
  buffer.writeln('SUMMARY:${escapeIcsText(courseTitle)}');

  // 只有 coursePlace 非空时才添加 LOCATION
  if (coursePlace.isNotEmpty) {
    buffer.writeln('LOCATION:${escapeIcsText(coursePlace)}');
  }

  // 只有 courseInstructor 非空时才添加 DESCRIPTION 和 ORGANIZER
  if (courseInstructor.isNotEmpty) {
    buffer.writeln('DESCRIPTION:${escapeIcsText('授课教师：$courseInstructor')}');
    buffer.writeln(
        'ORGANIZER;CN=${escapeIcsText(courseInstructor)}:mailto:no@email.provided');
  }

  buffer.writeln('DTSTART;TZID=Asia/Shanghai:$dtstart');
  buffer.writeln('DTEND;TZID=Asia/Shanghai:$dtend');

  final alarmParts = <String>[
    if (courseTitle.isNotEmpty) courseTitle,
    if (coursePlace.isNotEmpty) coursePlace,
    if (courseInstructor.isNotEmpty) courseInstructor,
  ];
  final alarmDescription = escapeIcsText(alarmParts.join(' | '));

  buffer.writeln('BEGIN:VALARM');
  buffer.writeln('ACTION:DISPLAY');
  buffer.writeln('DESCRIPTION:$alarmDescription');
  buffer.writeln('TRIGGER:$triggerTime');
  buffer.writeln('END:VALARM');

  buffer.writeln('END:VEVENT');

  return buffer.toString();
}
