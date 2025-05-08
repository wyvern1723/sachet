import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
// import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/utils/services/path_provider_service.dart';
// import 'package:sachet/widgets/classpage_widgets/switch_actived_app_file_dialog.dart';
// import 'package:provider/provider.dart';
import 'package:sachet/widgets/settingspage_widgets/palette_settings_widgets/palette_card.dart';
import 'package:sachet/widgets/settingspage_widgets/palette_settings_widgets/showcase_palette_card.dart';

class PaletteSettingsPage extends StatefulWidget {
  const PaletteSettingsPage({super.key});

  @override
  State<PaletteSettingsPage> createState() => _PaletteSettingsPageState();
}

class _PaletteSettingsPageState extends State<PaletteSettingsPage> {
  List<FileSystemEntity> filesPathList = [];

  /// 获取课程颜色数据文件列表并刷新界面
  Future<void> _getCourseColorFileList() async {
    await CachedDataStorage().ls(AppFolder.courseColor.name).then((value) {
      setState(() {
        filesPathList = value;
      });
    });
  }

  // /// 切换课程配色方案
  // Future switchCourseColorFile() async {
  //   var result = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) => SwitchActivedAppFileDialog(
  //       dialogTitle: '选择课程配色方案',
  //       fileDirectory: AppFilePath.courseColor.path,
  //       settingsFilePath: context.read<SettingsProvider>().courseColorFilePath,
  //     ),
  //   );
  //   if (result is String) {
  //     context.read<SettingsProvider>().setCourseColorFilePath(result);
  //   } else if (result == true) {
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _getCourseColorFileList();
  }

  @override
  Widget build(BuildContext context) {
    // String courseColorFilePath = context.select<SettingsProvider, String>(
    //     (settingsProvider) => settingsProvider.courseColorFilePath);
    return Scaffold(
      appBar: AppBar(
        title: const Text('配色管理'),
      ),
      body: ListView(
        children: [
          // Padding(
          //   padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
          //   child: Text(
          //     '设置',
          //     style: TextStyle(color: Theme.of(context).colorScheme.primary),
          //   ),
          // ),
          // // 当前配色方案
          // ListTile(
          //   leading: const Align(
          //       widthFactor: 1,
          //       alignment: Alignment.centerLeft,
          //       child: Icon(Icons.palette)),
          //   title: const Text('当前配色方案'),
          //   subtitle: Text(courseColorFilePath != ''
          //       ? courseColorFilePath.split(Platform.pathSeparator).last
          //       : '无'),
          //   // trailing: const Icon(Icons.arrow_forward_outlined),
          //   onTap: () {
          //     switchCourseColorFile();
          //   },
          // ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
            child: Text(
              '调色板',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ShowcasePaletteCard(
            paletteTitle: 'Material Design 2 shade400',
            paletteColor: materialColorsShade400,
          ),
          if (filesPathList.isNotEmpty)
            ...List.generate(filesPathList.length, (index) {
              Map courseColorData = CachedDataStorage().getDecodedDataSync(
                path: filesPathList[index].path,
                type: Map,
              );
              return PaletteCard(
                filePath: filesPathList[index].path,
                courseColorData: courseColorData,
                refresh: (value) => refresh(value),
              );
            }),
          // TODO: 添加新配色方案
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: 8.0),
          //   child: ListTile(
          //     title: const Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.end,
          //       children: [
          //         Icon(Icons.add),
          //         SizedBox(width: 4.0),
          //         Text('添加新配色方案'),
          //       ],
          //     ),
          //     iconColor: Theme.of(context).colorScheme.primary,
          //     textColor: Theme.of(context).colorScheme.primary,
          //     onTap: () {},
          //   ),
          // ),
        ],
      ),
    );
  }

  refresh(bool value) {
    setState(() {});
  }
}
