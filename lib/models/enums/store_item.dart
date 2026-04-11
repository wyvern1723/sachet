/// 学号、密码、cookie 的 keyName,防止 typo
// 因为一开始只有一个教务系统（强智教务系统），所以强智教务系统储存的 key 没有后缀。
// 如果修改，用户更新后将导致读取不到之前登录的信息。
enum StoreItem {
  // *****强智教务系统*****
  /// 用户姓名（强智教务系统）
  nameQZ('name'),

  /// 用户学号/用户名（强智教务系统）
  studentIDQZ('studentID'),

  /// 用户密码（强智教务系统）
  passwordQZ('password'),

  /// 用户登录成功的 cookie（强智教务系统）
  cookieQZ('cookie'),

  // *****正方教务系统*****
  /// 用户姓名（正方教务系统）
  nameZF('nameZF'),

  /// 用户学号/用户名（正方教务系统）
  studentIDZF('studentIDZF'),

  /// 用户密码（正方教务系统）
  passwordZF('passwordZF'),

  /// 用户登录成功的 cookie（正方教务系统）
  cookieZF('cookieZF');

  const StoreItem(this.keyName);
  final String keyName;
}
