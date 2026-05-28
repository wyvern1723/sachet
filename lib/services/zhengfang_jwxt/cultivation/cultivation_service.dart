import 'package:sachet/providers/zhengfang_user_provider.dart';

import '../auto_login_retry.dart';
import 'models/curriculum_response_zf.dart';
import 'models/queryable_major_response_zf.dart';
import 'models/school_major_response_zf.dart';
import 'cultivation_query_options/fetch_cultivation_query_options.dart';
import 'cultivation_query_options/parse_cultivation_query_options.dart';
import 'cultivation_queryable_majors/fetch_cultivation_queryable_majors.dart';
import 'cultivation_queryable_majors/parse_cultivation_queryable_majors.dart';
import 'cultivation_school_majors/fetch_cultivation_school_majors.dart';
import 'cultivation_school_majors/parse_cultivation_school_majors.dart';
import 'fetch_curriculum.dart';
import 'parse_curriculum.dart';

class CultivationService {
  const CultivationService();

  /// 获取正方教务系统培养方案查询页面的年级、学院、专业的下拉选项及默认选中值。
  ///
  /// Return:
  ///
  /// ```
  /// (
  /// Map<年级显示名称: 年级代码>,
  /// Map<学院显示名称: 学院代码>,
  /// Map<专业显示名称: 专业代码>,
  /// String 默认选中的年级代码,
  /// String 默认选中的学院代码,
  /// String 默认选中的专业代码,
  /// )
  /// ```
  Future<
      ({
        Map<String, String> grades,
        Map<String, String> schools,
        Map<String, String> majors,
        String? selectedGrade,
        String? selectedSchool,
        String? selectedMajor,
      })> getCultivationQueryOptions({
    required String cookie,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final html = await fetchCultivationQueryOpionsZF(cookie: activeCookie);
        return parseCultivationQueryOptionsFromHtmlZF(html);
      },
    );
  }

  /// 获取正方教务系统培养方案查询页面的学院下属专业列表
  Future<List<SchoolMajorResponseZF>> getCultivationSchoolMajors({
    required String cookie,
    required String shoolId,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final json = await fetchCultivationSchoolMajorsZF(
          cookie: activeCookie,
          shoolId: shoolId,
        );
        return parseCultivationSchoolMajorsZF(json);
      },
    );
  }

  /// 获取正方教务系统培养方案页面查询到的可查询培养方案（课程信息）的专业
  ///
  /// 吐槽一下教务系统的奇葩逻辑：
  /// 选了年级和学院后，还必须选一个「学院下的专业」，才能查出「可查询培养方案的专业」。
  ///
  /// 实际上：
  /// - 学院下的专业有很多干扰项（如“微专业”、“辅修专业” 和一些没见过的专业等）。
  /// - 如果把「学院下的专业」选为 "全部"，查询出来的就是该学院下干净、正常的专业列表，即此学院下所有可以查询培养方案的专业。
  ///
  /// 如果对于用户直接隐藏「学院下的专业」这个选项并默认传 "全部" 是最合理的。
  /// 但出于尊重教务系统的操作逻辑，我们依然保留了「学院下的专业」这个选项。
  Future<List<QueryableMajorResponseZF>> getCultivationQueryableMajors({
    required String cookie,
    required ZhengFangUserProvider? zhengFangUserProvider,

    /// 年级代码，如 "2023"
    required String gradeId,

    /// 学院代码，如 "050" => 机力院
    required String schoolId,

    /// 专业代码
    required String majorId,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final json = await fetchCultivationQueryableMajorsZF(
          cookie: activeCookie,
          gradeId: gradeId,
          schoolId: schoolId,
          majorId: majorId,
        );
        return parseCultivationQueryableMajorsZF(json);
      },
    );
  }

  /// 从正方教务系统获取培养方案的课程信息
  ///
  /// 获取的部分课程的课程英文名是乱码的，这是教务系统的问题。
  /// 虽然在网页的课程信息表格里不显示课程英文名，但在 “执行计划概览“ PDF 里的课程英文名也是乱码的
  Future<List<CurriculumResponseZF>> getCurriculum({
    required String cookie,
    required String queryMajorId,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final json = await fetchCurriculumZF(
          cookie: activeCookie,
          queryMajorId: queryMajorId,
        );
        return parseCurriculumZF(json);
      },
    );
  }
}
