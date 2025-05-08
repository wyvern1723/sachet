import 'package:flutter/material.dart';

/// 正在登录 SnackBar
SnackBar loggingInSnackBar(BuildContext context) {
  return SnackBar(
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
    content: Row(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(width: 20),
        Text(
          '登录中...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
      ],
    ),
  );
}
