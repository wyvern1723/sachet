import 'package:flutter/material.dart';

class LoginExpiredQZ extends StatelessWidget {
  const LoginExpiredQZ({
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
        // GestureDetector(
        //   child:  Text(
        //     '登录',
        //     style: TextStyle(
        //       color: Theme.of(context).colorScheme.primary,
        //       // decoration: TextDecoration.underline,
        //     ),
        //   ),
        //   onTap: () {
        //     Navigator.of(context).pushNamed('/login');
        //   },
        // ),

        // TextButton.icon(
        //   icon: const Icon(Icons.login),
        //   onPressed: () {
        //     Navigator.of(context).pushNamed('/login');
        //   },
        //   label: const Text('登录'),
        // ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/login').then((value) {
              var onGoBackFunc = onGoBack;
              if (onGoBackFunc != null) {
                onGoBackFunc(value);
              }
            });
          },
          child: Text('登录'),
        ),
        // const Text('。')
      ],
    );
  }
}
