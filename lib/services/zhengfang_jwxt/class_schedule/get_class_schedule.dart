import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:sachet/constants/app_constants.dart';

import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/services/zhengfang_jwxt/class_schedule/fetch_class_schedule.dart';
import 'package:sachet/services/zhengfang_jwxt/class_schedule/parse_class_schedule.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/utils/transform.dart';

/// 获取指定学年的课表。
///
/// [semesterYear] 是学年，格式为 "YYYY"，例如 "2025" 指 2025-2026 学年。
///
/// [semesterIndex] 是学期编号，如 1 表示第一学期，2 表示第二学期。正方教务最多有3个学期，但湘大只有2个学期。
///
/// 返回 [存储的课程表文件路径,存储的课程配色文件路径]，失败时抛出异常。
///
/// 示例：
/// ```dart
/// final result = await getClassScheduleZF(
///   semesterYear: '2025',
///   semesterIndex: '1',
/// );
/// ```
Future getClassScheduleZF({
  required String cookie,
  required String semesterYear, // 学年，如 '2025'=> 指 2025-2026 学年
  required String semesterIndex, // 学期编号，1=> 第1学期，2=>第二学期，3=>第三学期
}) async {
  final jsonData = await fetchClassScheduleZF(
    cookie: cookie,
    semesterYear: semesterYear,
    semesterIndex: semesterIndex,
  );
  final scheduleList = await parseClassScheduleZF(jsonData);
  final semester = ClassScheduleDataParserZF.parseSemester(jsonData);

  // 把课程表文件储存到 AppSupportDir
  String outputClassScheduleFilePath =
      await storeClassScheduleFile(scheduleList, semester);

  // 获取课程名称 List
  List courseTitleList =
      ClassScheduleDataParserZF.parseCourseTitleList(jsonData);

  // 把课程名称 List 交给 randomAllocateColorToCourse()，让它随机分配预设的几种颜色
  Map courseColorData =
      randomAllocateColorToCourse(courseTitleList: courseTitleList);

  // 把随机分配后得到的 {课程1:颜色1,课程2:颜色2,.......} 文件储存到 AppSupportDir
  String outputCourseColorpath = await storeRandomizationCourseColorFile(
    courseColorData: courseColorData,
    semester: semester,
  );

  return [outputClassScheduleFilePath, outputCourseColorpath];
}

/// 给课程随机分配颜色
///
/// return {'课程1': color1Hex,'课程2': color2Hex,......}
Map<String, String> randomAllocateColorToCourse({
  required List courseTitleList,
  List<Color>? palette,
}) {
  // 如果没有传入 palette, 默认为 materialColorsShade400（Material Color Scheme Shade 400）
  palette ??= materialColorsShade400;

  Map<String, String> courseColorMap = {};

  // 打乱 palette List
  palette.shuffle();

  // 如果 课程名称 List 的长度超出了 预设配色 List 的长度
  if (courseTitleList.length > palette.length) {
    int newValue = 0;
    for (int i = 0; i < courseTitleList.length; i++) {
      if (newValue > palette.length - 1) {
        // 如果 newValue 超出了 length 就给 newValue 减去 colors.length, 重新从 0 开始
        newValue = newValue - palette.length;
      }
      courseColorMap.addAll(
        {
          courseTitleList[i]: colorToHex(
            palette[newValue],
            includeHashSign: true,
            toUpperCase: true,
          )
        },
      );
      newValue++;
    }
  } else {
    for (int i = 0; i < courseTitleList.length; i++) {
      courseColorMap.addAll({
        courseTitleList[i]: colorToHex(
          palette[i],
          includeHashSign: true,
          toUpperCase: true,
        )
      });
    }
  }

  return courseColorMap;
}

/// 把随机分配完颜色的 课程-颜色 文件储存到 AppSupportDir
///
/// return 文件保存的路径
Future<String> storeRandomizationCourseColorFile({
  required Map courseColorData,
  required String semester,
}) async {
  String fileName =
      "course_color_${semester}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json";

  await CachedDataStorage().writeFileToAppSupportDir(
    fileName: fileName,
    folder: AppFolder.courseColor.name,
    value: formatJsonEncode(courseColorData),
  );

  final localPath = await CachedDataStorage().getPath();
  final filePath = path.join(localPath, AppFolder.courseColor.name, fileName);
  return filePath;
}

/// 把课程表文件储存到 AppSupportDir
///
/// return 储存课程表文件的路径
Future<String> storeClassScheduleFile(
    List allSessionsCoursesData, String semester) async {
  String fileName =
      "class_schedule_${semester}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json";

  await CachedDataStorage().writeFileToAppSupportDir(
    fileName: fileName,
    folder: AppFolder.classSchedule.name,
    value: formatJsonEncode(allSessionsCoursesData),
  );

  final localPath = await CachedDataStorage().getPath();
  final filePath = path.join(localPath, AppFolder.classSchedule.name, fileName);

  return filePath;
}
