import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ImportJsonDataDialog extends StatefulWidget {
  const ImportJsonDataDialog({super.key, required this.file});
  final File file;

  @override
  State<ImportJsonDataDialog> createState() => _ImportJsonDataDialogState();
}

class _ImportJsonDataDialogState extends State<ImportJsonDataDialog> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      textEditingController = TextEditingController(
          text: path.basenameWithoutExtension(widget.file.path));
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _key = GlobalKey<FormState>();

    return AlertDialog(
      title: Text('确认导入该文件？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('文件名: ${path.basename(widget.file.path)}'),
          Text('文件路径: ${widget.file.path}'),
          Text(
              '修改时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.file.lastModifiedSync())}'),
          Text('大小: ${widget.file.statSync().size} B'),
          SizedBox(height: 4),
          Row(
            children: [
              Text('储存文件名: '),
              SizedBox(width: 4),
              Flexible(
                child: Form(
                  key: _key,
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
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixText: '.json',
                    ),
                  ),
                ),
              ),
            ],
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
            if (_key.currentState!.validate()) {
              Navigator.pop(context, textEditingController.text);
            }
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
