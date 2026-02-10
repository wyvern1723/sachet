import 'package:flutter/foundation.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_score_pdf_link.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_score_pdf_link.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

/// 正方教务系统打印成绩单，获取成绩单链接
///
/// Return: "https://jw.xtu.edu.cn/jwglxt/templete/scorePrint/score_202312345678_1769943281937.pdf"
Future<String> getScorePdfLinkZF({
  required String cookie,
  required ZhengFangUserProvider? zhengFangUserProvider,

  /// 成绩单格式
  ///
  /// e.g.,
  /// "中文主修成绩单（最高考虑加分）": "10530-zw-zgmrgs",
  /// "中文主修成绩单（全程）": "10530-zw-qcmrgs",
  /// "中文主修成绩单（最高不考虑加分）": "10530-zw-zgbjf"
  required String type,
}) async {
  try {
    final result = await fetchScorePdfLinkZF(cookie: cookie, type: type);
    return parseScorePdfLinkZF(result.toString());
  } catch (e) {
    if (e == '获取成绩单链接失败: Http status code = 901, 验证身份信息失败') {
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
        // 登录失败，重新抛出 fetchScorePdfLinkZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;

      // 重新加载数据
      final result = await fetchScorePdfLinkZF(cookie: newCookie, type: type);
      return parseScorePdfLinkZF(result.toString());
    } else {
      rethrow;
    }
  }
}
