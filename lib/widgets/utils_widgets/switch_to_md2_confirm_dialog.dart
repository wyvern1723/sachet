import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sachet/providers/theme_provider.dart';

class SwitchToMD2ConfirmDialog extends StatelessWidget {
  /// 是否确认切换至 Material Design 2 的 Dialog
  const SwitchToMD2ConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      icon: Icon(Icons.elderly_woman_rounded, size: 28),
      title: Text('切换至旧版设计？'),
      content: Text(
        '当前 UI 以 Material Design 3 设计语言为规范。切换至 Material Design 2 可能导致部分组件样式不统一，造成体验降级。',
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<ThemeProvider>().setIsMD3(false);
            Navigator.pop(context);
          },
          child: const Text('仍要切换'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('不切换'),
        ),
      ],
    );
  }
}
