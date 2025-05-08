import 'package:flutter/material.dart';

class LogoutDialog extends StatefulWidget {
  /// 提示退出登录的 Dialog，如果确认登出，返回 <bool>_isDeleteCachedData(是否删除缓存数据)
  /// 
  /// 不退出登录，return null
  ///
  /// 退出登录，但不删除缓存数据 return false
  ///
  /// 退出登录，并删除缓存数据 return true
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isDeleteCachedData = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('退出登录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('您确定要退出登录吗？'),
          CheckboxMenuButton(
            value: _isDeleteCachedData,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _isDeleteCachedData = value;
                });
              }
            },
            child: Text('删除缓存数据'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _isDeleteCachedData),
          child: const Text('确认'),
        ),
      ],
    );
  }
}
