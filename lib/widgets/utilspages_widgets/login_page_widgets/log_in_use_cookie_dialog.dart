import 'package:flutter/material.dart';

class LogInUseCookieDialog extends StatefulWidget {
  /// 填入 cookie 登录 Dialog
  const LogInUseCookieDialog({super.key});

  @override
  State<LogInUseCookieDialog> createState() => _LogInUseCookieDialogState();
}

class _LogInUseCookieDialogState extends State<LogInUseCookieDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('使用 Cookie 登录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 6),
          SizedBox(height: 10),
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              isDense: true,
              labelText: '请填入 Cookie',
              hintText: 'JSESSIONID=XXXXXX......',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.visiblePassword,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _textEditingController.text);
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
