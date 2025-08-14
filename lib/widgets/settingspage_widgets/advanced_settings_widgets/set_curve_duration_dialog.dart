import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'package:sachet/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SetCurveDurationDialog extends StatefulWidget {
  const SetCurveDurationDialog({super.key});

  @override
  State<SetCurveDurationDialog> createState() => _SetCurveDurationDialogState();
}

class _SetCurveDurationDialogState extends State<SetCurveDurationDialog> {
  final curveDurationontroller =
      TextEditingController(text: SettingsProvider().curveDuration.toString());

  @override
  void dispose() {
    curveDurationontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置翻页动画时长'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          const SizedBox(height: 10),
          TextField(
            key: const Key('size'),
            controller: curveDurationontroller,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              suffixText: 'ms',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            context.read<SettingsProvider>().setCurveDuration(
                int.tryParse(curveDurationontroller.text) ?? 1500);
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
