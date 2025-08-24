import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/generate_course_color.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/get_class_schedule.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_class_schedule.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_class_schedule.dart';

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
