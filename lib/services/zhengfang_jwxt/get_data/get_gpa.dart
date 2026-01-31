import 'package:flutter/foundation.dart';
import 'package:sachet/models/gpa_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_gpa.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_gpa.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

/// 从正方教务系统获取绩点排名
Future<GpaResponseZF> getGPAZF({
  required String cookie,

  /// 起始学年学期，如 "202503", "202512"
  required String startSemester,

  /// 终止学年学期，如 "202503", "202512"
  required String endSemester,

  /// 课程属性. 全部: "", 必修: "bx", 选修: "xx"
  required String courseType,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  try {
    final result = await fetchGPAZF(
      cookie: cookie,
      startSemester: startSemester,
      endSemester: endSemester,
      courseType: courseType,
    );
    return parseGPAZF(result);
  } catch (e) {
    if (e == '获取成绩数据失败: Http status code = 302, 可能需要重新登录') {
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
        // 登录失败，重新抛出 fetchGPAZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;

      // 重新加载数据
      final result = await fetchGPAZF(
        cookie: newCookie,
        startSemester: startSemester,
        endSemester: endSemester,
        courseType: courseType,
      );
      return parseGPAZF(result);
    } else {
      rethrow;
    }
  }
}
