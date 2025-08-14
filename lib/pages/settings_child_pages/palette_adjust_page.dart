import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/widgets/settingspage_widgets/color_settings_widgets/add_new_color_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/color_settings_widgets/change_color_dialog.dart';

class PaletteAdjustPage extends StatefulWidget {
  // 针对一个配色文件的调整
  const PaletteAdjustPage({
    super.key,
    required this.colorFilePath,
    required this.courseColorData,
  });
  final String colorFilePath;
  final Map courseColorData;

  @override
  State<PaletteAdjustPage> createState() => _PaletteAdjustPageState();
}

class _PaletteAdjustPageState extends State<PaletteAdjustPage> {
  Map _courseColorData = {};

  Future showChangeColorDialog(String courseTitle) async {
    Color? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeColorDialog(
          // TODO: handle entryList[courseTitle] is null
          pickerColor: _courseColorData[courseTitle].toString().toColor() ??
              Colors.cyan.shade400,
        );
      },
    );
    if (result != null) {
      _courseColorData[courseTitle] = colorToHex(
        result,
        includeHashSign: true,
        toUpperCase: true,
      );

      // 储存
      await CachedDataStorage().reWriteDataByFilePath(
        formatJsonEncode(_courseColorData),
        widget.colorFilePath,
      );

      // 刷新
      setState(() {});
    }
  }

  Future addNewColor() async {
    Map<String, String>? courseAndColor = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddNewColorDialog();
        });
    if (courseAndColor != null) {
      // 添加一项
      _courseColorData.addAll(courseAndColor);
      // 再储存回去
      await CachedDataStorage().reWriteDataByFilePath(
        formatJsonEncode(_courseColorData),
        widget.colorFilePath,
      );
    }
    // 刷新
    setState(() {});
  }

  @override
  void initState() {
    _courseColorData = Map.of(widget.courseColorData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配色调整'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            itemCount: _courseColorData.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_courseColorData.keys.elementAt(index)),
                trailing: GestureDetector(
                  onTap: () async {
                    await showChangeColorDialog(
                      _courseColorData.keys.elementAt(index),
                    );
                  },
                  child: ClipOval(
                    child: Container(
                      height: 38,
                      width: 38,
                      color: (_courseColorData.values.elementAt(index))
                              .toString()
                              .toColor() ??
                          Colors.green.shade400,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 4.0),
                  Text('添加新配色'),
                ],
              ),
              iconColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.primary,
              onTap: () async {
                await addNewColor();
              },
            ),
          ),
        ],
      ),
    );
  }
}
