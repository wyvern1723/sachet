import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sachet/models/app_folder.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/class_schedule_data_listview_widgets/import_json_data_dialog.dart';
import 'package:sachet/pages/settings_child_pages/view_data_page.dart';

class CachedDataListviewPage extends StatefulWidget {
  const CachedDataListviewPage({super.key});

  @override
  State<CachedDataListviewPage> createState() => _CachedDataListviewPageState();
}

class _CachedDataListviewPageState extends State<CachedDataListviewPage> {
  List<FileSystemEntity> filesPathList = [];

  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scaffoldMessenger.hideCurrentSnackBar();
    super.dispose();
  }

  Future importCachedData() async {
    // 使用 FilePicker 选择文件
    FilePickerResult? filePaths = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    String? filePath = filePaths?.files.first.path;

    // 如果选择了一个文件
    if (filePaths?.isSinglePick == true && filePath != null) {
      File file = File(filePath);

      // 显示确认导入文件 Dialog
      String? result = await showDialog(
        context: context,
        builder: (BuildContext context) => ImportJsonDataDialog(
          file: file,
        ),
      );
      if (result != null) {
        // 写入缓存文件到 ApplicationSupportDirectory
        await CachedDataStorage().writeFileToAppSupportDir(
            fileName: result != ''
                ? '$result.json'
                : "file_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json",
            folder: AppFolder.cachedData.name,
            value: file.readAsStringSync());

        // 导入成功 SnackBar
        final snackBar = SnackBar(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
          content: Row(
            children: [
              Icon(
                Icons.done_outlined,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 20),
              Text(
                '导入成功',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ],
          ),
        );
        if (!mounted) {
          return;
        }
        // 显示导入成功 SnackBar
        _scaffoldMessenger.showSnackBar(snackBar);
        // 刷新文件列表
        await _getCachedDataFileList();
        // 显示 导入成功 SnackBar 3秒
        await Future.delayed(const Duration(seconds: 3));
        // 隐藏导入成功 SnackBar
        _scaffoldMessenger.hideCurrentSnackBar();
      }
    }
  }

  /// 获取缓存数据文件列表并刷新界面
  Future<void> _getCachedDataFileList() async {
    await CachedDataStorage().ls(AppFolder.cachedData.name).then((value) {
      setState(() {
        filesPathList = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getCachedDataFileList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("缓存数据查看"),
      ),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '存在缓存',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.toc,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
          ...List.generate(
            filesPathList.length,
            (index) => ListTile(
              title: Text(
                  '${fileNameToMeaning[path.basename(filesPathList[index].path)] ?? path.basename(filesPathList[index].path)}'),
              subtitle: Text('${filesPathList[index].path}'
                  '\n'
                  '更新时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(File(filesPathList[index].path).lastModifiedSync())}'),
              isThreeLine: true,
              trailing: Align(
                widthFactor: 1,
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(fadeTransitionPageRoute(ViewCachedDataPage(
                            filePath: filesPathList[index].path)))
                        .then((_) => {_ ? setState(() {}) : null});
                  },
                  icon: Icon(Icons.edit_note),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.file_open),
                SizedBox(width: 4.0),
                Text('导入数据'),
              ],
            ),
            iconColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.primary,
            onTap: () async {
              await importCachedData();
            },
          ),
        ],
      ),
    );
  }
}
