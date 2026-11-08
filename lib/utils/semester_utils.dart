import 'package:path/path.dart' as path;

/// 课程表文件名中的学期，如 class_schedule_2025-2026-2_20250825111641.json 中的 2025-2026-2
final RegExp _classScheduleFileNameSemesterRegExp =
    RegExp(r'class_schedule_(\d{4}-\d{4}-\d+)');

/// 宽松提取学期，例如 xxxxxxx2025-2026-2xxxxxxx.json 中的 2025-2026-2
final RegExp _semesterRegExp = RegExp(r'(\d{4}-\d{4}-\d+)');

/// 从课程表文件路径提取学期，无法识别时返回 null
String? semesterFromFileName(String filePath) {
  final String fileName = path.basenameWithoutExtension(filePath);
  return _classScheduleFileNameSemesterRegExp.firstMatch(fileName)?.group(1) ??
      _semesterRegExp.firstMatch(fileName)?.group(1);
}
