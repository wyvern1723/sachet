import 'package:flutter/material.dart';

class ManualLoginSuccessfulDialog extends StatelessWidget {
  const ManualLoginSuccessfulDialog({
    super.key,
    required this.userName,
    required this.cookie,
  });
  final String userName;
  final String cookie;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('获取登录信息成功'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.waving_hand_outlined),
              const SizedBox(width: 16),
              Text("欢迎您！$userName"),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'cookie: $cookie',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context)
              ..pop() // 关掉这个 Dialog
              ..pop() // 关掉手动登录页面
              ..pop(true); // 关掉登录页面，并返回 true
          },
          child: Text('完成'),
        ),
      ],
    );
  }
}
