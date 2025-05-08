import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/widgets/settingspage_widgets/color_settings_widgets/change_color_dialog.dart';

class AddNewColorDialog extends StatefulWidget {
  const AddNewColorDialog({super.key});

  @override
  State<AddNewColorDialog> createState() => _AddNewColorDialogState();
}

class _AddNewColorDialogState extends State<AddNewColorDialog> {
  TextEditingController textEditingController = TextEditingController();
  final _key = GlobalKey<FormState>();

  Color pickerColor = Colors.cyan.shade400;

  Future showChangeColorDialog() async {
    Color? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeColorDialog(
          pickerColor: pickerColor,
        );
      },
    );
    if (result != null) {
      setState(() {
        pickerColor = result;
      });
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('添加新配色'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: Form(
                key: _key,
                child: TextFormField(
                  controller: textEditingController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "请输入课程名称";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(labelText: '课程名称'),
                ),
              )),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  await showChangeColorDialog();
                },
                child: ClipOval(
                  child: Container(
                    height: 38,
                    width: 38,
                    color: pickerColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_key.currentState!.validate()) {
              Map<String, String> result = {
                textEditingController.text: colorToHex(
                  pickerColor,
                  includeHashSign: true,
                  toUpperCase: true,
                )
              };
              Navigator.pop(context, result);
            }
          },
          child: Text('确认'),
        )
      ],
    );
  }
}
