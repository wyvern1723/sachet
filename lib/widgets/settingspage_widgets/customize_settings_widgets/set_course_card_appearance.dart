import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:sachet/widgets/settingspage_widgets/color_settings_widgets/change_color_dialog.dart';

// 外观调整 Widget
class SetCourseCardAppearance extends StatefulWidget {
  const SetCourseCardAppearance({
    super.key,
    required this.category,
    required this.dialogTitle,
    required this.icon,
  });

  final CourseItemCategory category; // 要设置（更改）的变量的类别 Title / Place / Instructor
  final String dialogTitle;
  final IconData icon;

  @override
  State<SetCourseCardAppearance> createState() =>
      _SetCourseCardAppearanceState();
}

class _SetCourseCardAppearanceState extends State<SetCourseCardAppearance> {
  @override
  Widget build(BuildContext context) {
    var courseCardSettings = context.watch<CourseCardSettingsProvider>();
    return ListTile(
        leading: Align(
          widthFactor: 1,
          alignment: Alignment.centerLeft,
          child: Icon(widget.icon),
        ),
        title: Text(widget.dialogTitle),
        subtitle: Text(widget.category == CourseItemCategory.title
            ? '字体大小: ${courseCardSettings.titleFontSize} 字重:  ${courseCardSettings.titleFontWeight + 1} 最大行数:  ${courseCardSettings.titleMaxLines}'
            : widget.category == CourseItemCategory.place
                ? '字体大小: ${courseCardSettings.placeFontSize} 字重:  ${courseCardSettings.placeFontWeight + 1} 最大行数:  ${courseCardSettings.placeMaxLines}'
                : '字体大小: ${courseCardSettings.instructorFontSize} 字重:  ${courseCardSettings.instructorFontWeight + 1} 最大行数:  ${courseCardSettings.instructorMaxLines}'),
        onTap: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return SetCourseCardAppearanceDialog(
                  dialogTitle: widget.dialogTitle,
                  category: widget.category,
                );
              });
        });
  }
}

enum CourseItemCategory { title, place, instructor }

class SetCourseCardAppearanceDialog extends StatefulWidget {
  const SetCourseCardAppearanceDialog({
    super.key,
    required this.dialogTitle,
    required this.category,
  });
  final String dialogTitle;
  final CourseItemCategory category;
  @override
  State<SetCourseCardAppearanceDialog> createState() =>
      _SetCourseCardAppearanceDialogState();
}

class _SetCourseCardAppearanceDialogState
    extends State<SetCourseCardAppearanceDialog> {
  late int _MLValue;
  late double _FWValue;
  late String _TCValue;
  late TextEditingController valueController;
  @override
  void initState() {
    super.initState();
    switch (widget.category) {
      case CourseItemCategory.title:
        _MLValue = context.read<CourseCardSettingsProvider>().titleMaxLines;
        _FWValue = context
            .read<CourseCardSettingsProvider>()
            .titleFontWeight
            .toDouble();
        _TCValue = context.read<CourseCardSettingsProvider>().titleTextColor;
        valueController = TextEditingController(
            text: context
                .read<CourseCardSettingsProvider>()
                .titleFontSize
                .toString());
        break;
      case CourseItemCategory.place:
        _MLValue = context.read<CourseCardSettingsProvider>().placeMaxLines;
        _FWValue = context
            .read<CourseCardSettingsProvider>()
            .placeFontWeight
            .toDouble();
        _TCValue = context.read<CourseCardSettingsProvider>().placeTextColor;
        valueController = TextEditingController(
            text: context
                .read<CourseCardSettingsProvider>()
                .placeFontSize
                .toString());
        break;
      case CourseItemCategory.instructor:
        _MLValue =
            context.read<CourseCardSettingsProvider>().instructorMaxLines;
        _FWValue = context
            .read<CourseCardSettingsProvider>()
            .instructorFontWeight
            .toDouble();
        _TCValue =
            context.read<CourseCardSettingsProvider>().instructorTextColor;
        valueController = TextEditingController(
            text: context
                .read<CourseCardSettingsProvider>()
                .instructorFontSize
                .toString());
        break;
    }
  }

  void showChangeColorDialog(Color pickerColor) async {
    Color? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeColorDialog(
          pickerColor: pickerColor,
        );
      },
    );
    if (result != null) {
      _TCValue = colorToHex(
        result,
        includeHashSign: true,
        toUpperCase: true,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),

            // 修改字体大小
            const Row(children: [
              Text('字体大小', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Icon(Icons.format_size_outlined, size: 20)
            ]),
            const SizedBox(height: 6),
            TextField(
              key: const Key('size'),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              inputFormatters: [
                FilteringTextInputFormatter.deny('-'),
                FilteringTextInputFormatter.deny(',')
              ],
              controller: valueController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // 修改字重的滑条(Slider)
            const Row(children: [
              Text('字重', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Icon(Icons.format_bold_outlined, size: 20)
            ]),
            const SizedBox(height: 4),
            Slider(
              key: const Key('FW'),
              value: _FWValue + 1,
              min: 1,
              max: 9,
              divisions: 8,
              label: (_FWValue + 1).round().toString(),
              onChanged: (value) {
                setState(() {
                  _FWValue = value - 1;
                });
              },
            ),

            const SizedBox(height: 10),

            const Row(children: [
              Text('文字颜色', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Icon(Icons.format_color_text_outlined, size: 20)
            ]),
            GestureDetector(
              onTap: () {
                showChangeColorDialog(
                    colorFromHex(_TCValue) ?? Colors.white70.withOpacity(0.95));
              },
              child: SizedBox(
                height: 48,
                width: 48,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  color: colorFromHex(_TCValue),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 修改最大行数
            const Row(children: [
              Text('最大行数', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Icon(Icons.wrap_text, size: 20)
            ]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_MLValue > 0) {
                      setState(() {
                        _MLValue--;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                  ),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 10),
                Text(
                  '$_MLValue',
                  // style: Theme.of(context).textTheme.titleLarge,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _MLValue++;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                  ),
                  child: const Icon(Icons.add),
                )
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            switch (widget.category) {
              case CourseItemCategory.title:
                context.read<CourseCardSettingsProvider>().setTitleFontSize(
                    double.tryParse(valueController.text) ?? 13.0);
                context
                    .read<CourseCardSettingsProvider>()
                    .setTitleMaxLines(_MLValue);
                context
                    .read<CourseCardSettingsProvider>()
                    .setTitleTextColor(_TCValue);
                context
                    .read<CourseCardSettingsProvider>()
                    .setTitleFontWeight(_FWValue.toInt());
                break;
              case CourseItemCategory.place:
                context.read<CourseCardSettingsProvider>().setPlaceFontSize(
                    double.tryParse(valueController.text) ?? 12.0);
                context
                    .read<CourseCardSettingsProvider>()
                    .setPlaceMaxLines(_MLValue);
                context
                    .read<CourseCardSettingsProvider>()
                    .setPlaceTextColor(_TCValue);
                context
                    .read<CourseCardSettingsProvider>()
                    .setPlaceFontWeight(_FWValue.toInt());
                break;
              case CourseItemCategory.instructor:
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorFontSize(
                        double.tryParse(valueController.text) ?? 12.0);
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorMaxLines(_MLValue);
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorTextColor(_TCValue);
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorFontWeight(_FWValue.toInt());
                break;
            }
            Navigator.pop(context);
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
