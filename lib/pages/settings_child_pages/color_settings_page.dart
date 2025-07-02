import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/utils/services/path_provider_service.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/widgets/classpage_widgets/switch_actived_app_file_dialog.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sachet/widgets/settingspage_widgets/color_settings_widgets/add_new_color_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/color_settings_widgets/change_color_dialog.dart';

class ColorSettingsPage extends StatefulWidget {
  const ColorSettingsPage({super.key});

  @override
  State<ColorSettingsPage> createState() => _ColorSettingsPageState();
}

class _ColorSettingsPageState extends State<ColorSettingsPage> {
  Map _courseColorData = {};
  late bool isCurrentCourseColorFileExist; // 当前是否有课程配色文件在使用

  /// 获取当前课程颜色数据
  void _getCurrentCourseColorData() async {
    if (isCurrentCourseColorFileExist) {
      Map courseColorData = await CachedDataStorage().getDecodedData(
        path: context.read<SettingsProvider>().courseColorFilePath,
        type: Map,
      );
      setState(() {
        _courseColorData = Map.of(courseColorData);
      });
    }
  }

  /// 切换课程配色方案
  Future switchCourseColorFile() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => SwitchActivedAppFileDialog(
        dialogTitle: '选择课程配色方案',
        fileDirectory: AppFolder.courseColor.name,
        settingsFilePath: context.read<SettingsProvider>().courseColorFilePath,
      ),
    );
    if (result is String) {
      context.read<SettingsProvider>().setCourseColorFilePath(result);
      _getCurrentCourseColorData();
    } else if (result == true) {
      _getCurrentCourseColorData();
    }
    await context.read<SettingsProvider>().refreshCourseColorData();
  }

  void showChangeColorDialog(String courseTitle) async {
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
        context.read<SettingsProvider>().courseColorFilePath,
      );
      // 刷新
      await context.read<SettingsProvider>().refreshCourseColorData();
      setState(() {});
    }
  }

  Future addNewColor() async {
    if (isCurrentCourseColorFileExist) {
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
          context.read<SettingsProvider>().courseColorFilePath,
        );
      }
      // 刷新
      await context.read<SettingsProvider>().refreshCourseColorData();
      setState(() {});
    } else {
      String? fileName = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CreateNewCourseColorFileDialog();
          });

      if (fileName != null) {
        // 写入配色文件到 ApplicationSupportDirectory
        await CachedDataStorage().writeFileToAppSupportDir(
          fileName: fileName != ''
              ? '$fileName.json'
              : "course_color_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json",
          folder: AppFolder.courseColor.name,
          value: '',
        );
        String appDir = await CachedDataStorage().getPath();
        String filePath =
            '$appDir${Platform.pathSeparator}${AppFolder.courseColor.name}${Platform.pathSeparator}$fileName.json';
        context.read<SettingsProvider>().setCourseColorFilePath(filePath);
        isCurrentCourseColorFileExist = true;
      }
    }
  }

  @override
  void initState() {
    isCurrentCourseColorFileExist =
        context.read<SettingsProvider>().courseColorFilePath !=
            ''; // 如果没有设置路径，路径默认是 ''（空的字符串）
    _getCurrentCourseColorData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String courseColorFilePath = context.select<SettingsProvider, String>(
        (settingsModel) => settingsModel.courseColorFilePath); //  当前使用的配色文件路径
    return Scaffold(
      appBar: AppBar(
        title: const Text('配色调整'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Align(
                widthFactor: 1,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.palette)),
            title: const Text('当前配色方案'),
            subtitle: Text(
              isCurrentCourseColorFileExist
                  ? courseColorFilePath.split(Platform.pathSeparator).last
                  : '无',
            ),
            onTap: () {
              switchCourseColorFile();
            },
          ),
          // ...ListTile.divideTiles(
          //   context: context,
          //   tiles: List.generate(
          //     _courseColorData.length,
          //     (index) => ListTile(
          //       title: Text(_courseColorData.keys.elementAt(index)),
          //       trailing: GestureDetector(
          //         onTap: () {
          //           showChangeColorDialog(
          //               _courseColorData.keys.elementAt(index));
          //         },
          //         child: ClipOval(
          //           child: Container(
          //             height: 38,
          //             width: 38,
          //             color: Color(_courseColorData.values.elementAt(index)),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          ListView.separated(
            shrinkWrap: true,
            itemCount: _courseColorData.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_courseColorData.keys.elementAt(index)),
                trailing: GestureDetector(
                  onTap: () {
                    showChangeColorDialog(
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
                // TODO:让图标和文字对齐
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 4.0),
                  Text('添加新配色'),
                ],
              ),
              iconColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                addNewColor();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CreateNewCourseColorFileDialog extends StatefulWidget {
  const CreateNewCourseColorFileDialog({super.key});

  @override
  State<CreateNewCourseColorFileDialog> createState() =>
      _CreateNewCourseColorFileDialogState();
}

class _CreateNewCourseColorFileDialogState
    extends State<CreateNewCourseColorFileDialog> {
  TextEditingController textEditingController = TextEditingController();

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('创建新文件'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('当前还没有任何配色文件，新建一个？'),
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_key.currentState!.validate()) {
              Navigator.pop(context, textEditingController.text);
            }
          },
          child: Text('确认'),
        )
      ],
    );
  }
}
