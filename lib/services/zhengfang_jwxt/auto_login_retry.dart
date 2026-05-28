import 'package:flutter/foundation.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';

import 'login/zhengfang_login_service.dart';

/// 默认的 Cookie/Session 失效检查逻辑。
///
/// 匹配正方教务系统常见的重定向 (302) 与 验证失败 (901) 状态码。
bool _defaultSessionCheck(Object error) {
  final errorStr = error.toString();
  return errorStr.contains('Http status code = 302') ||
      errorStr.contains('Http status code = 901');
}

/// 自动登录与重试封装
///
/// 用于教务系统请求的统一拦截处理：
///
/// 当检测到 Cookie/Session 失效时，自动使用保存的学号和密码（如果有）重新登录，并用新 Cookie 重试原请求。
///
/// 实现无感重登录和重试。
///
/// 示例：
/// ```dart
/// return withAutoLoginRetry(
///   initialCookie: cookie,
///   zhengFangUserProvider: zhengFangUserProvider,
///   action: (activeCookie) async {
///     final result = await fetchGrade(cookie: activeCookie);
///     return parseGrade(result);
///   },
/// );
/// ```
Future<T> withAutoLoginRetry<T>({
  required String initialCookie,
  required ZhengFangUserProvider? zhengFangUserProvider,
  bool Function(Object error) isSessionExpired = _defaultSessionCheck,
  required Future<T> Function(String activeCookie) action,
}) async {
  try {
    // 首次尝试：使用初始 Cookie 发起请求
    return await action(initialCookie);
  } catch (e) {
    // 判断是否是登录失效
    if (!isSessionExpired(e)) rethrow;

    // 检查是否具备自动登录的条件
    if (zhengFangUserProvider == null) rethrow;

    final studentID = zhengFangUserProvider.user.studentID;
    if (studentID == null) rethrow;

    final password = await ZhengFangUserProvider.readPassword();
    if (password == null) rethrow;

    // 尝试静默重新登录
    final zhengFangLoginService = ZhengFangLoginService();
    try {
      await zhengFangLoginService.login(
        username: studentID,
        password: password,
      );
      await zhengFangUserProvider.setCookie(zhengFangLoginService.cookie);
    } catch (reLoginError) {
      if (kDebugMode) {
        print('教务系统自动重新登录失败: $reLoginError');
      }
      // 登录失败，抛出首次请求抓到的错误（仍提示登录失效，需要用户手动去登录）
      throw e;
    }

    // 登录成功，拿到新 Cookie 进行重试
    final newCookie = ZhengFangUserProvider.cookie;
    return await action(newCookie);
  }
}
