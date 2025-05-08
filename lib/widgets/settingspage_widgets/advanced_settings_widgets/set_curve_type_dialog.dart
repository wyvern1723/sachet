import 'package:flutter/material.dart';
import 'package:sachet/provider/app_global.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:provider/provider.dart';

enum CurveType {
  easing,
  curves,
}

class SetCurveTypeDialog extends StatefulWidget {
  const SetCurveTypeDialog({super.key});

  @override
  State<SetCurveTypeDialog> createState() => _SetCurveTypeDialogState();
}

class _SetCurveTypeDialogState extends State<SetCurveTypeDialog> {
  CurveType curveView = SettingsProvider().curveType.contains('Easing')
      ? CurveType.easing
      : CurveType.curves;

  @override
  Widget build(BuildContext context) {
    String curveType = context.select<SettingsProvider, String>(
        (settingsProvider) => settingsProvider.curveType);
    return SimpleDialog(
      title: const Text("选择动画曲线"),
      clipBehavior: Clip.hardEdge, // 如果不设置，长按的水波效果会超出 dialog
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<CurveType>(
              segments: const <ButtonSegment<CurveType>>[
                ButtonSegment<CurveType>(
                  value: CurveType.easing,
                  label: Text('Easing'),
                ),
                ButtonSegment<CurveType>(
                  value: CurveType.curves,
                  label: Text('Curves'),
                ),
              ],
              selected: <CurveType>{curveView},
              onSelectionChanged: (Set<CurveType> newSelection) {
                setState(() {
                  // By default there is only a single segment that can be
                  // selected at one time, so its value is always the first
                  // item in the selected set.
                  curveView = newSelection.first;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        curveView == CurveType.easing
            ? Column(
                children: [
                  ...curveTypes.entries
                      .where((e) => e.key.contains('Easing'))
                      .map(
                        (entry) => RadioListTile(
                          value: entry.key,
                          groupValue: curveType,
                          onChanged: (_value) {
                            Navigator.pop(context);
                            context
                                .read<SettingsProvider>()
                                .setCurveType(entry.key);
                          },
                          title: Text(entry.key),
                          selected: curveType == entry.key,
                        ),
                      )
                ],
              )
            : Column(
                children: [
                  ...curveTypes.entries
                      .where((e) => e.key.contains('Curves'))
                      .map(
                        (entry) => RadioListTile(
                          value: entry.key,
                          groupValue: curveType,
                          onChanged: (_value) {
                            Navigator.pop(context);
                            context
                                .read<SettingsProvider>()
                                .setCurveType(entry.key);
                          },
                          title: Text(entry.key),
                          selected: curveType == entry.key,
                        ),
                      )
                ],
              ),
      ],
    );
  }
}
