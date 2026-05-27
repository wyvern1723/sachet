import 'package:flutter/foundation.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/models/queryable_major_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/cultivation_queryable_majors/fetch_cultivation_queryable_majors.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/cultivation_queryable_majors/parse_cultivation_queryable_majors.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

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
Future<List<QueryableMajorResponseZF>> getCultivationQueryableMajorsZF({
  required String cookie,
  required ZhengFangUserProvider? zhengFangUserProvider,

  /// 年级代码，如 "2023"
  required String gradeId,

  /// 学院代码，如 "050" => 机力院
  required String schoolId,

  /// 专业代码
  required String majorId,
}) async {
  try {
    final json = await fetchCultivationQueryableMajorsZF(
      cookie: cookie,
      gradeId: gradeId,
      schoolId: schoolId,
      majorId: majorId,
    );
    return parseCultivationQueryableMajorsZF(json);
  } catch (e) {
    if (e == '获取可查询专业失败: Http status code = 901, 验证身份信息失败') {
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
        // 登录失败，重新抛出 fetchCultivationQueryableMajorsZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;

      // 重新加载数据
      final json = await fetchCultivationQueryableMajorsZF(
        cookie: newCookie,
        gradeId: gradeId,
        schoolId: schoolId,
        majorId: majorId,
      );
      return parseCultivationQueryableMajorsZF(json);
    } else {
      rethrow;
    }
  }
}
