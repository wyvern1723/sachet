import 'package:flutter/material.dart';

class LogoutDialog extends StatefulWidget {
  /// 提示退出登录的 Dialog，如果确认退出登录，return true
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('退出登录'),
      content: const Text('您确定要退出登录吗？'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('确认'),
        ),
      ],
    );
  }
}
