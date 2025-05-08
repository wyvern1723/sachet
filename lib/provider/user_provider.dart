import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  static late FlutterSecureStorage _secureStorage;
  static late User _user;
  static FlutterSecureStorage get secureStorage => _secureStorage;
  User get user => _user;
  static String get cookie => _user.cookie ?? '';

  /// 从 SecureStorage 获取储存的 学号和密码
  static Future init() async {
    _secureStorage = FlutterSecureStorage();
    String? name = await _secureStorage.read(key: StoreItem.name.keyName);
    String? studentID =
        await _secureStorage.read(key: StoreItem.studentID.keyName);
    // String? password =
    //     await _secureStorage.read(key: StoreItem.password.keyName);
    String? cookie = await _secureStorage.read(key: StoreItem.cookie.keyName);
    if (cookie != null) {
      User secureStorageUser = User()
        ..name = name
        ..studentID = studentID
        ..cookie = cookie;
      _user = secureStorageUser;
    } else {
      _user = User();
    }
  }

  // 是否登录 (如果有 cookie，则证明登录过)
  bool get isLogin => _user.cookie != null;

  /// 设置用户信息
  Future setUser(User newUser) async {
    if (newUser.cookie != _user.cookie) {
      _user = newUser;
      if (_user.name != null) {
        await _secureStorage.write(
          key: StoreItem.cookie.keyName,
          value: _user.cookie,
        );
      }
      if (_user.name != null) {
        await _secureStorage.write(
          key: StoreItem.name.keyName,
          value: _user.name,
        );
      }
      if (_user.studentID != null) {
        await _secureStorage.write(
          key: StoreItem.studentID.keyName,
          value: _user.studentID,
        );
      }
      notifyListeners();
    }
  }

  /// 删除用户信息
  void deleteUser() {
    _user = User();
    // _secureStorage.delete(key: StoreItem.password.keyName);
    // _secureStorage.delete(key: StoreItem.cookie.keyName);
    // _secureStorage.delete(key: StoreItem.studentID.keyName);
    // _secureStorage.delete(key: StoreItem.name.keyName);
    // _secureStorage.deleteAll();
    notifyListeners();
  }
}

class User {
  String? name;
  String? studentID;
  String? password;
  String? cookie;

  User({this.name, this.studentID, this.password, this.cookie});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    studentID = json['studentID'];
    password = json['password'];
    cookie = json['cookie'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['studentID'] = this.studentID;
    data['password'] = this.password;
    data['cookie'] = this.cookie;
    return data;
  }
}

/// 学号、密码、cookie 的 keyName,防止 typo
enum StoreItem {
  name('name'),
  studentID('studentID'),
  password('password'),
  cookie('cookie');

  const StoreItem(this.keyName);
  final String keyName;
}
