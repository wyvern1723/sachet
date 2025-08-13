import 'package:flutter/material.dart';

/// 显示登录错误信息的 SnackBar
SnackBar errorInfoSnackBar(BuildContext context, String errorText) {
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.onErrorContainer,
    padding: const EdgeInsets.symmetric(
      vertical: 20.0,
      horizontal: 24.0,
    ),
    content: Row(
      children: [
        Icon(
          Icons.warning,
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            errorText,
            style: TextStyle(
              // color: Theme.of(context).colorScheme.onInverseSurface,
              color: Theme.of(context).colorScheme.error,
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            ),
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}
