import 'package:flutter/material.dart';
import 'package:sachet/pages/utilspages/zhengfang_jwxt_login_page.dart';

class LoginExpiredZF extends StatelessWidget {
  /// 登录失效，登录过期（正方教务系统）
  const LoginExpiredZF({
    super.key,
    this.onGoBack, // 从登录页面返回后回调的函数
  });

  final Function? onGoBack;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('登录失效，请重新'),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const ZhengFangJwxtLoginPage();
                },
              ),
            ).then((value) {
              var onGoBackFunc = onGoBack;
              if (onGoBackFunc != null) {
                onGoBackFunc(value);
              }
            });
          },
          child: Text('登录'),
        ),
      ],
    );
  }
}
