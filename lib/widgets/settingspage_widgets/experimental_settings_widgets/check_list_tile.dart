import 'package:flutter/material.dart';

class CheckListTile extends StatelessWidget {
  /// 显示一个标题和值的布尔状态的 ListTile
  ///
  /// 根据 [value] 在 trailing 显示绿色 ✓ 或红色 X
  ///
  /// 可用于表示权限状态，例如，「通知权限 ✅」「自启动权限 ❌」
  const CheckListTile({
    super.key,
    required this.title,
    required this.value,
    this.onTap,
  });
  final String title;
  final bool value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: value
          ? Icon(Icons.done, color: Colors.green)
          : Icon(Icons.close, color: Colors.red),
      onTap: onTap,
    );
  }
}
