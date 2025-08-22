/// 学号、密码、cookie 的 keyName,防止 typo
enum StoreItem {
  // *****强智教务系统*****
  /// 用户姓名（强智教务系统）
  nameQZ('name'),

  /// 用户学号/用户名（强智教务系统）
  studentIDQZ('studentID'),

  /// 用户密码（强智教务系统）
  passwordQZ('password'),

  /// 用户登录成功的 cookie（强智教务系统）
  cookieQZ('cookie');

  const StoreItem(this.keyName);
  final String keyName;
}
