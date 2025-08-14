/// 学号、密码、cookie 的 keyName,防止 typo
enum StoreItem {
  name('name'),
  studentID('studentID'),
  password('password'),
  cookie('cookie');

  const StoreItem(this.keyName);
  final String keyName;
}
