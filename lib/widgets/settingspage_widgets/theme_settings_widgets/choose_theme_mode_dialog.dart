import 'package:flutter/material.dart';
import 'package:sachet/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ChooseThemeModeDialog extends StatelessWidget {
  const ChooseThemeModeDialog({super.key, required this.themeMode});
  final int themeMode;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("选择主题"),
      clipBehavior: Clip.hardEdge, // 如果不设置，长按的水波效果会超出 dialog
      children: List.generate(
        intAndThemeMode.length,
        (int index) {
          return RadioListTile(
            value: index,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeProvider>().setThemeMode(value);
                Navigator.pop(context);
              }
            },
            title: Text('${intAndThemeMode[index]}'),
            selected: themeMode == index,
          );
        },
      ),
    );
  }
}
