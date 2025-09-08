import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_semester_start_date.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_semester_start_date.dart';

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
