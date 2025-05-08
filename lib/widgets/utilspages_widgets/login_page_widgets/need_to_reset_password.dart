import 'package:flutter/material.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class NeedToResetPasswordDialog extends StatelessWidget {
  const NeedToResetPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('需要重设密码'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 8),
          Text("用户名与密码正确，但可能需要重设密码。"),
          SizedBox(height: 8),
          Text('使用初始密码第一次登录教务系统？请在浏览器访问教务系统，登录后设置新密码。')
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            launchUrl(Uri.parse(jwxtBaseUrlHttps));
          },
          child: Text('在浏览器访问教务系统'),
        ),
      ],
    );
  }
}
