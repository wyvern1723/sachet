import 'package:flutter/material.dart';
import 'package:sachet/models/jwxt_type.dart';
import 'package:sachet/providers/qiangzhi_user_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';

/// 登录页面 Provider
class LoginPageProvider extends ChangeNotifier {
  /// 是否正在登录（按下登录按钮后，正在登录，禁止再次按下）
  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  /// 是否记住密码
  bool _isRememberPassword = false;
  bool get isRememberPassword => _isRememberPassword;

  void setIsLoggingIn(bool value) {
    _isLoggingIn = value;
    notifyListeners();
  }

  void setIsRememberPassword(bool value, JwxtType jwxtType) {
    if (value == false) {
      // 如果选择不记住密码，删除之前储存的密码（曾经可能选择记住，但这次又改变选择，那就不再储存，删除以前储存的）
      switch (jwxtType) {
        case JwxtType.qiangzhi:
          QiangZhiUserProvider.deletePassword();
          break;
        case JwxtType.zhengfang:
          ZhengFangUserProvider.deletePassword();
          break;
      }
    }
    _isRememberPassword = value;
    notifyListeners();
  }
}
