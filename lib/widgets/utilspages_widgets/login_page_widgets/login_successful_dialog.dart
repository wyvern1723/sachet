import 'package:flutter/material.dart';

class LoginSuccessfulDialog extends StatelessWidget {
  const LoginSuccessfulDialog({
    super.key,
    required this.userName,
  });
  final String userName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('登录成功'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.waving_hand_outlined),
              const SizedBox(width: 16),
              Text(
                "欢迎您！$userName",
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // 关掉这个 Dialog
            Navigator.pop(context, true); // 关掉这个登录页面，并返回 true
          },
          child: Text('完成'),
        ),
      ],
    );
  }
}
