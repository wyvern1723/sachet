import 'package:flutter/material.dart';

class RenameAppFileDialog extends StatefulWidget {
  const RenameAppFileDialog({super.key, required this.fileName});
  final String fileName;

  @override
  State<RenameAppFileDialog> createState() => _RenameAppFileDialogState();
}

class _RenameAppFileDialogState extends State<RenameAppFileDialog> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      textEditingController = TextEditingController(text: widget.fileName);
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text('重命名'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Form(
            key: _formKey,
            // TODO: 检查文件名称非法字符，检查是否与现有文件名称重复
            child: TextFormField(
              controller: textEditingController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "请输入文件名";
                } else {
                  return null;
                }
              },
              autofocus: true,
              decoration: const InputDecoration(
                isDense: true,
                suffixText: '.json',
              ),
            ),
          )
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
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, textEditingController.text);
            }
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
