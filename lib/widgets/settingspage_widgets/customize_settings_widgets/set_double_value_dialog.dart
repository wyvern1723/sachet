import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 设置 CourseCardSettings 中 double value (eg. CardHeight 课程卡片高度，CardBorderRadius 卡片圆角大小)
class SetDoubleValueDialog extends StatefulWidget {
  const SetDoubleValueDialog({
    super.key,
    required this.title,
    required this.value,
  });
  final String title;
  final double value;

  @override
  State<SetDoubleValueDialog> createState() => _SetDoubleValueDialogState();
}

class _SetDoubleValueDialogState extends State<SetDoubleValueDialog> {
  late TextEditingController _doubleValueController;
  @override
  void initState() {
    super.initState();
    _doubleValueController =
        TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _doubleValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          const SizedBox(height: 10),
          TextField(
            key: const Key('size'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.deny('-'),
              FilteringTextInputFormatter.deny(',')
            ],
            controller: _doubleValueController,
            decoration: const InputDecoration(
              isDense: true,
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
          onPressed: () {
            double? value = double.tryParse(_doubleValueController.text);
            Navigator.pop(context, value);
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
