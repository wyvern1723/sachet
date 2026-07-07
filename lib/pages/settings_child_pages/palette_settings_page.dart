import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/enums/app_folder.dart';
// import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
// import 'package:sachet/widgets/classpage_widgets/switch_actived_app_file_dialog.dart';
// import 'package:provider/provider.dart';
import 'package:sachet/widgets/settingspage_widgets/palette_settings_widgets/palette_card.dart';
import 'package:sachet/widgets/settingspage_widgets/palette_settings_widgets/showcase_palette_card.dart';

class _PaletteData {
  final String path;
  final Map<String, dynamic> data;

  _PaletteData({required this.path, required this.data});
}

class PaletteSettingsPage extends StatefulWidget {
  const PaletteSettingsPage({super.key});

  @override
  State<PaletteSettingsPage> createState() => _PaletteSettingsPageState();
}

class _PaletteSettingsPageState extends State<PaletteSettingsPage> {
  List<_PaletteData> _palettes = [];

  Future<void> _loadPalettesData() async {
    try {
      final files =
          await CachedDataStorage.lsByModifiedTime(AppFolder.courseColor.name);

      List<_PaletteData> loadedPalettes = [];

      for (final file in files) {
        final decodedData = await CachedDataStorage.getDecodedMap(file.path);

        loadedPalettes.add(
          _PaletteData(path: file.path, data: decodedData),
        );
      }

      if (!mounted) return;

      setState(() {
        _palettes = loadedPalettes;
      });
    } catch (e) {
      debugPrint('加载配色数据失败: $e');
      if (!mounted) return;
    }
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

  void refresh(bool value) {
    _loadPalettesData();
  }

  @override
  void initState() {
    super.initState();
    _loadPalettesData();
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
          if (_palettes.isNotEmpty)
            ..._palettes.map((palette) => PaletteCard(
                  filePath: palette.path,
                  courseColorData: palette.data,
                  refresh: (value) => refresh(value),
                )),
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
}
