import 'package:flutter/foundation.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/models/school_major_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/cultivation_school_majors/fetch_cultivation_school_majors.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/cultivation_school_majors/parse_cultivation_school_majors.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

/// 获取正方教务系统培养方案查询页面的学院下属专业列表
Future<List<SchoolMajorResponseZF>> getCultivationSchoolMajorsZF({
  required String cookie,
  required ZhengFangUserProvider? zhengFangUserProvider,
  required String shoolId,
}) async {
  try {
    final json = await fetchCultivationSchoolMajorsZF(
      cookie: cookie,
      shoolId: shoolId,
    );
    return parseCultivationSchoolMajorsZF(json);
  } catch (e) {
    if (e == '获取培养方案学院下属专业列表失败: Http status code = 302, 可能需要重新登录') {
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
        // 登录失败，重新抛出 fetchCultivationSchoolMajorsZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;
      // 重新加载数据
      final json = await fetchCultivationSchoolMajorsZF(
        cookie: newCookie,
        shoolId: shoolId,
      );
      return parseCultivationSchoolMajorsZF(json);
    } else {
      rethrow;
    }
  }
}
