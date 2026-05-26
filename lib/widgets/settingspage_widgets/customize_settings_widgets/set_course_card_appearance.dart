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
    final courseCardSettings = context.watch<CourseCardSettingsProvider>();

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
          builder: (context) => SetCourseCardAppearanceDialog(
            dialogTitle: widget.dialogTitle,
            category: widget.category,
          ),
        );
      },
    );
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
  late int _titleMaxLines;
  late double _titleFontWeight;
  late String _titleTextColor;

  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    switch (widget.category) {
      case CourseItemCategory.title:
        _titleMaxLines =
            context.read<CourseCardSettingsProvider>().titleMaxLines;
        _titleFontWeight = context
            .read<CourseCardSettingsProvider>()
            .titleFontWeight
            .toDouble();
        _titleTextColor =
            context.read<CourseCardSettingsProvider>().titleTextColor;
        valueController = TextEditingController(
            text: context
                .read<CourseCardSettingsProvider>()
                .titleFontSize
                .toString());
        break;
      case CourseItemCategory.place:
        _titleMaxLines =
            context.read<CourseCardSettingsProvider>().placeMaxLines;
        _titleFontWeight = context
            .read<CourseCardSettingsProvider>()
            .placeFontWeight
            .toDouble();
        _titleTextColor =
            context.read<CourseCardSettingsProvider>().placeTextColor;
        valueController = TextEditingController(
            text: context
                .read<CourseCardSettingsProvider>()
                .placeFontSize
                .toString());
        break;
      case CourseItemCategory.instructor:
        _titleMaxLines =
            context.read<CourseCardSettingsProvider>().instructorMaxLines;
        _titleFontWeight = context
            .read<CourseCardSettingsProvider>()
            .instructorFontWeight
            .toDouble();
        _titleTextColor =
            context.read<CourseCardSettingsProvider>().instructorTextColor;
        valueController = TextEditingController(
            text: context
                .read<CourseCardSettingsProvider>()
                .instructorFontSize
                .toString());
        break;
    }
  }

  Future showChangeColorDialog(BuildContext context, Color pickerColor) async {
    Color? result = await showDialog(
      context: context,
      builder: (context) => ChangeColorDialog(pickerColor: pickerColor),
    );

    if (!context.mounted) return;

    if (result != null) {
      setState(() {
        _titleTextColor = colorToHex(
          result,
          includeHashSign: true,
          toUpperCase: true,
        );
      });
    }
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
              value: _titleFontWeight + 1,
              min: 1,
              max: 9,
              divisions: 8,
              label: (_titleFontWeight + 1).round().toString(),
              onChanged: (value) {
                setState(() => _titleFontWeight = value - 1);
              },
            ),

            const SizedBox(height: 10),

            const Row(children: [
              Text('文字颜色', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Icon(Icons.format_color_text_outlined, size: 20)
            ]),
            GestureDetector(
              onTap: () async {
                await showChangeColorDialog(
                  context,
                  colorFromHex(_titleTextColor) ??
                      Colors.white70.withOpacity(0.95),
                );
              },
              child: SizedBox(
                height: 48,
                width: 48,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  color: colorFromHex(_titleTextColor),
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
                    if (_titleMaxLines > 0) {
                      setState(() => _titleMaxLines--);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                  ),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 10),
                Text(
                  '$_titleMaxLines',
                  // style: Theme.of(context).textTheme.titleLarge,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _titleMaxLines++),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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
          onPressed: () => Navigator.pop(context),
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
                    .setTitleMaxLines(_titleMaxLines);
                context
                    .read<CourseCardSettingsProvider>()
                    .setTitleTextColor(_titleTextColor);
                context
                    .read<CourseCardSettingsProvider>()
                    .setTitleFontWeight(_titleFontWeight.toInt());
                break;
              case CourseItemCategory.place:
                context.read<CourseCardSettingsProvider>().setPlaceFontSize(
                    double.tryParse(valueController.text) ?? 12.0);
                context
                    .read<CourseCardSettingsProvider>()
                    .setPlaceMaxLines(_titleMaxLines);
                context
                    .read<CourseCardSettingsProvider>()
                    .setPlaceTextColor(_titleTextColor);
                context
                    .read<CourseCardSettingsProvider>()
                    .setPlaceFontWeight(_titleFontWeight.toInt());
                break;
              case CourseItemCategory.instructor:
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorFontSize(
                        double.tryParse(valueController.text) ?? 12.0);
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorMaxLines(_titleMaxLines);
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorTextColor(_titleTextColor);
                context
                    .read<CourseCardSettingsProvider>()
                    .setInstructorFontWeight(_titleFontWeight.toInt());
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
