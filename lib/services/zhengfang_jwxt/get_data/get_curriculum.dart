import 'package:flutter/foundation.dart';
import 'package:sachet/models/zhengfang_jwxt/response/curriculum_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_curriculum.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_curriculum.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

/// 从正方教务系统获取培养方案的课程信息
///
/// 获取的部分课程的课程英文名是乱码的，这是教务系统的问题。
/// 虽然在网页的课程信息表格里不显示课程英文名，但在 “执行计划概览“ PDF 里的课程英文名也是乱码的
Future<List<CurriculumResponseZF>> getCurriculumZF({
  required String cookie,
  required String queryMajorId,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  try {
    final json = await fetchCurriculumZF(
      cookie: cookie,
      queryMajorId: queryMajorId,
    );
    return parseCurriculumZF(json);
  } catch (e) {
    if (e == '获取课程信息失败: Http status code = 901, 验证身份信息失败') {
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
        // 登录失败，重新抛出 fetchCurriculumZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;

      // 重新加载数据
      final json = await fetchCurriculumZF(
        cookie: newCookie,
        queryMajorId: queryMajorId,
      );
      return parseCurriculumZF(json);
    } else {
      rethrow;
    }
  }
}
