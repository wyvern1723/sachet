import 'package:flutter/foundation.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_score_pdf_types.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_score_pdf_types.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

/// 正方教务系统打印成绩单，获取可选成绩单格式
///
/// Return:
///
/// e.g.,
///
/// {
/// "中文主修成绩单（最高考虑加分）": "10530-zw-zgmrgs",
/// "中文主修成绩单（全程）": "10530-zw-qcmrgs",
/// "中文主修成绩单（最高不考虑加分）": "10530-zw-zgbjf"
/// }
Future<Map> getScorePdfTypesZF({
  required String cookie,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  try {
    final result = await fetchScorePdfTypesZF(cookie: cookie);
    return parseScorePdfTypesFromHtmlZF(result.toString());
  } catch (e) {
    if (e == '获取可选成绩单格式失败: Http status code = 901, 验证身份信息失败') {
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
        // 登录失败，重新抛出 fetchScorePdfTypesZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;

      // 重新加载数据
      final result = await fetchScorePdfTypesZF(cookie: newCookie);
      return parseScorePdfTypesFromHtmlZF(result.toString());
    } else {
      rethrow;
    }
  }
}
