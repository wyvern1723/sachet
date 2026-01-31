import 'package:flutter/foundation.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_grade_semesters.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_grade_semesters_and_alert_text.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

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
    })> getGradeSemestersAndAlertTextZF({
  required String cookie,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  try {
    final html = await fetchGradeSemetersZF(cookie: cookie);
    return parseGradeSemestersAndDangerTextFromHtmlZF(html);
  } catch (e) {
    if (e == '获取可查询学期数据失败: Http status code = 302, 可能需要重新登录') {
      if (zhengFangUserProvider == null) {
        rethrow;
      }

      final studentID = zhengFangUserProvider.user.studentID;
      if (studentID == null) {
        rethrow;
      }

      final password = await ZhengFangUserProvider.readPassword();
      if (password == null) {
        rethrow;
      }

      final zhengFangLoginService = ZhengFangLoginService();
      try {
        await zhengFangLoginService.login(
          username: studentID,
          password: password,
        );
        String cookie = zhengFangLoginService.cookie;
        await zhengFangUserProvider.setCookie(cookie);
      } catch (reLoginError) {
        if (kDebugMode) {
          print(reLoginError);
        }
        // 登录失败，重新抛出 fetchGradeSemetersZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;
      // 重新加载数据
      final html = await fetchGradeSemetersZF(cookie: newCookie);
      return parseGradeSemestersAndDangerTextFromHtmlZF(html);
    } else {
      rethrow;
    }
  }
}
