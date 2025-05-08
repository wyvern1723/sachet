import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ChangeColorDialog extends StatefulWidget {
  final Color pickerColor;
  const ChangeColorDialog({
    super.key,
    required this.pickerColor,
  });

  @override
  State<ChangeColorDialog> createState() => _ChangeColorDialogState();
}

class _ChangeColorDialogState extends State<ChangeColorDialog> {
  late Color _pickerColor;
  @override
  void initState() {
    _pickerColor = widget.pickerColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorPicker(
            pickerColor: _pickerColor,
            onColorChanged: (Color color) => {
              setState(() {
                _pickerColor = color;
              })
            },
            colorPickerWidth: 300,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: true,
            labelTypes: [
              ColorLabelType.hex,
              ColorLabelType.rgb,
              ColorLabelType.hsv,
              ColorLabelType.hsl,
            ],
            displayThumbColor: true,
            paletteType: PaletteType.hslWithHue,
            pickerAreaBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
            hexInputBar: true,
            colorHistory: [],
            onHistoryChanged: (color) => {},
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
            Navigator.pop(context, _pickerColor);
          },
          child: Text('确定'),
        )
      ],
    );
  }
}
