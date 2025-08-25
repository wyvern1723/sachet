import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_class_schedule_semesters.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_class_schedule_semesters.dart';

/// 从正方教务系统获取课程表当前学年，可选学年和当前学期
///
/// 返回 (String 当前学年(如 "2025"), Map<学年标签: 对应的值>, String 当前学期的 Value (如 "3"=>第一学期，"12"=>第二学期))
/// e.g.
///
///  "2025",
/// {
///   "2030-2031": "2030",
///   "2029-2030": "2029",
///   "2028-2029": "2028",
///   "2027-2028": "2027",
///   "2026-2027": "2026",
///   "2025-2026": "2025",
///   "2024-2025": "2024",
///   "2023-2024": "2023",
///   "2022-2023": "2022",
///   "2021-2022": "2021",
///   "2020-2021": "2020",
///   "2019-2020": "2019",
///   "2018-2019": "2018",
///   "2017-2018": "2017",
///   "2016-2017": "2016",
///   "2015-2016": "2015",
///   "2014-2015": "2014",
///   "2013-2014": "2013",
///   "2012-2013": "2012",
///   "2011-2012": "2011",
///   "2010-2011": "2010",
///   "2009-2010": "2009",
///   "2008-2009": "2008",
///   "2007-2008": "2007",
///   "2006-2007": "2006",
///   "2005-2006": "2005",
///   "2004-2005": "2004",
///   "2003-2004": "2003",
///   "2002-2003": "2002",
///   "2001-2002": "2001"
/// },
/// "3")
Future<(String?, Map<String, String>, String?)> getClassScheduleSemestersZF({
  required String cookie,
}) async {
  final html = await fetchClassScheduleSemetersZF(cookie: cookie);
  final result = parseClassScheduleSemestersFromHtmlZF(html);
  return (result.$1, result.$2, result.$3);
}
