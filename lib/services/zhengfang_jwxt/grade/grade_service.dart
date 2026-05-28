import 'package:sachet/providers/zhengfang_user_provider.dart';

import '../auto_login_retry.dart';
import 'grade_semesters_and_alert_text/fetch_grade_semesters_and_alert_text.dart';
import 'grade_semesters_and_alert_text/parse_grade_semesters_and_alert_text.dart';
import 'fetch_grade.dart';
import 'parse_grade.dart';

class GradeService {
  const GradeService();

  /// 从正方教务系统获取成绩查询页面当前学年，可选学年，当前学期和页面显示的红色提醒文字(Danger Text)
  ///
  /// Return (
  /// String 当前学年(如 "2025"),
  /// Map<学年标签: 对应的值>,
  /// String 当前学期的 Value (如 "3"=>第一学期，"12"=>第二学期)
  /// List<String> 提醒文字的 List（每一行为一项）
  /// )
  ///
  /// e.g.
  ///
  /// ```
  /// (
  /// "2025",
  /// {
  ///   "全部": "",
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
  /// "3",
  /// ["【2025-2026学年1学期 未完全评价】","【2025-2026学年1学期正常考成绩】和【2025-2026学年1学期补考成绩】未开放查询!"]
  /// )
  /// ```
  Future<
      ({
        String? currentSemesterYear,
        Map<String, String> semestersYears,
        String? currentSemesterIndex,
        List<String> alertTexts,
      })> getGradeSemestersAndAlertText({
    required String cookie,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final html =
            await fetchGradeSemetersAndAlertTextZF(cookie: activeCookie);
        return parseGradeSemestersAndDangerTextFromHtmlZF(html);
      },
    );
  }

  /// 从正方教务系统获取考试成绩
  Future<List> getGrade({
    required String cookie,

    /// xnm 学年名，如 '2025'=> 指 2025-2026 学年
    required String semesterYear,

    /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期
    required String semesterIndex,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final result = await fetchGradeZF(
          cookie: activeCookie,
          semesterYear: semesterYear,
          semesterIndex: semesterIndex,
        );
        return parseGradeZF(result);
      },
    );
  }
}
