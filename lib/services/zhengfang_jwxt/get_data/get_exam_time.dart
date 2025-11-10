import 'package:flutter/foundation.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_exam_time.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_exam_time.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

/// 从正方教务系统获取考试时间
Future<List> getExamTimeZF({
  required String cookie,

  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年, ""=> 全部
  required String semesterYear,

  /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期, ""=> 全部
  required String semesterIndex,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  try {
    final result = await fetchExamTimeZF(
      cookie: cookie,
      semesterYear: semesterYear,
      semesterIndex: semesterIndex,
    );
    return parseExamTimeZF(result);
  } catch (e) {
    if (e == '获取考试时间数据失败: Http status code = 302, 可能需要重新登录') {
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
        // 登录失败，重新抛出 fetchExamTimeZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;

      // 重新加载数据
      final result = await fetchExamTimeZF(
        cookie: newCookie,
        semesterYear: semesterYear,
        semesterIndex: semesterIndex,
      );
      return parseExamTimeZF(result);
    } else {
      rethrow;
    }
  }
}
