import 'package:flutter/foundation.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/cultivation_query_options/fetch_cultivation_query_options.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/cultivation_query_options/parse_cultivation_query_options.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

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
    })> getCultivationQueryOptionsZF({
  required String cookie,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  try {
    final html = await fetchCultivationQueryOpionsZF(cookie: cookie);
    return parseCultivationQueryOptionsFromHtmlZF(html);
  } catch (e) {
    if (e == '获取培养方案可选数据失败: Http status code = 302, 可能需要重新登录') {
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
        // 登录失败，重新抛出 fetchCultivationQueryOpionsZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;
      // 重新加载数据
      final html = await fetchCultivationQueryOpionsZF(cookie: newCookie);
      return parseCultivationQueryOptionsFromHtmlZF(html);
    } else {
      rethrow;
    }
  }
}
