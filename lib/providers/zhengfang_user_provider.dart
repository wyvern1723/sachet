import 'package:flutter/material.dart';
import 'package:sachet/models/store_item.dart';
import 'package:sachet/models/user.dart';
import 'package:sachet/utils/storage/secure_storage_util.dart';

/// 正方教务系统的用户信息 Provider
class ZhengFangUserProvider extends ChangeNotifier {
  static final _secureStorageUtil = SecureStorageUtil();

  static User _user = User();
  User get user => _user;
  static String get cookie => _user.cookie ?? '';

  /// 是否登录 (如果有 cookie，则证明登录过)
  bool get isLogin => _user.cookie != null;

  /// 从 SecureStorage 获取储存的 学号和密码
  Future init() async {
    String? name = await _secureStorageUtil.read(key: StoreItem.nameZF.keyName);
    String? studentID =
        await _secureStorageUtil.read(key: StoreItem.studentIDZF.keyName);
    String? cookie =
        await _secureStorageUtil.read(key: StoreItem.cookieZF.keyName);

    // 如果有 cookie, 说明曾经登录过
    if (cookie != null) {
      _user = User()
        ..name = name
        ..studentID = studentID
        ..cookie = cookie;
      notifyListeners();
    }
  }

  /// 设置用户信息
  Future setUser(User newUser) async {
    if (newUser.cookie != _user.cookie) {
      _user = newUser;
      if (_user.cookie != null) {
        await _secureStorageUtil.save(
          key: StoreItem.cookieZF.keyName,
          value: _user.cookie,
        );
      }
      if (_user.name != null) {
        await _secureStorageUtil.save(
          key: StoreItem.nameZF.keyName,
          value: _user.name,
        );
      }
      if (_user.studentID != null) {
        await _secureStorageUtil.save(
          key: StoreItem.studentIDZF.keyName,
          value: _user.studentID,
        );
      }
      notifyListeners();
    }
  }

  /// 读取密码
  static Future<String?> readPassword() async {
    return _secureStorageUtil.read(key: StoreItem.passwordZF.keyName);
  }

  /// 保存密码
  static Future savePassword(String password) async {
    if (password != _user.password) {
      _user.password = password;

      await _secureStorageUtil.save(
        key: StoreItem.passwordZF.keyName,
        value: password,
      );
    }
  }

  /// 删除密码
  static void deletePassword() {
    _secureStorageUtil.delete(key: StoreItem.passwordZF.keyName);
  }

  /// 删除用户信息
  void deleteUser() {
    _user = User();
    _secureStorageUtil.deleteAll();
    notifyListeners();
  }
}
