import 'package:flutter/foundation.dart';
import 'package:sachet/models/free_classroom_filter_options.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_free_classroom_filter_options.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_free_classroom_filter_options.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

/// 获取空教室查询页面中多个下拉选择器的数据
///
/// 返回三个筛选项: 学年学期、教学楼、场地类别 的选项列表 Map<label: value> 和当前选中值。

Future<FreeClassroomFilterOptionsZF> getFreeClassroomFilterOptionsZF({
  required String cookie,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  try {
    final html = await fetchFreeClassroomFilterOptionsZF(cookie: cookie);
    return parseFreeClassroomFilterOptionsZF(html);
  } catch (e) {
    if (e == '获取可选数据失败: Http status code = 302, 可能需要重新登录') {
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
        // 登录失败，重新抛出 fetchFreeClassroomFilterOptionsZF() 的 error，（仍提示登录失效，需要用户手动去登录）
        throw e;
      }
      // 登录成功
      // 重新读取最新 cookie
      final newCookie = ZhengFangUserProvider.cookie;
      // 重新加载数据
      final html = await fetchFreeClassroomFilterOptionsZF(cookie: newCookie);
      return parseFreeClassroomFilterOptionsZF(html);
    } else {
      rethrow;
    }
  }
}
