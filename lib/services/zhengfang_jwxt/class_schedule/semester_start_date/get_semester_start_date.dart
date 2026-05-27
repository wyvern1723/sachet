import 'package:sachet/services/zhengfang_jwxt/class_schedule/semester_start_date/fetch_semester_start_date.dart';
import 'package:sachet/services/zhengfang_jwxt/class_schedule/semester_start_date/parse_semester_start_date.dart';

/// 获取当前学期开学日期
///
/// return (\<String>开学日期，\<DateTime>开学日期)
Future<(String, DateTime)> getSemesterStartDate({
  required String cookie,
}) async {
  final html = await fetchSemesterStartDate(cookie: cookie);
  final (String, DateTime) semesterStartDate =
      parseSemesterStartDateFromHtml(html);
  return semesterStartDate;
}
