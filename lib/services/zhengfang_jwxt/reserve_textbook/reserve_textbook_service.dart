import 'package:sachet/providers/zhengfang_user_provider.dart';

import '../auto_login_retry.dart';
import 'fetch_reserve_textbook_info.dart';
import 'models/reserve_textbook_response_zf.dart';
import 'parse_reserve_textbook_info.dart';
import 'reserve_textbook_semesters/fetch_reserve_textbook_semesters.dart';
import 'reserve_textbook_semesters/parse_reserve_textbook_semesters.dart';

class ReserveTextbookService {
  const ReserveTextbookService();

  /// 从正方教务系统获取教材预订查询页面可选学年，当前学年和当前学期
  ///
  /// Return (
  /// Map<学年标签: 对应的值>,
  /// String 当前学年(如 "2025"),
  /// String 当前学期的 Value (如 "3"=>第一学期，"12"=>第二学期)
  /// )
  ///
  /// e.g.
  ///
  /// ```
  /// (
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
  /// "2025",
  /// "12"
  /// )
  /// ```
  Future<
      ({
        String? currentSemesterYear,
        Map<String, String> semestersYears,
        String? currentSemesterIndex
      })> getReserveTextbookSemesters({
    required String cookie,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final html = await fetchReserveTextbookSemetersZF(cookie: activeCookie);
        return parseReserveTextbookSemestersFromHtmlZF(html);
      },
    );
  }

  /// 从正方教务系统获取教材预订的书籍信息
  Future<List<ReserveTextbookResponseZF>> getReserveTextbookInfo({
    required String cookie,

    /// xnm 学年名，如 '2025'=> 指 2025-2026 学年, ""=> 全部
    required String semesterYear,

    /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，""=> 全部
    required String semesterIndex,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final result = await fetchReserveTextbookInfoZF(
          cookie: activeCookie,
          semesterYear: semesterYear,
          semesterIndex: semesterIndex,
        );
        return parseReserveTextBookInfoZF(result);
      },
    );
  }
}
