import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/class_schedule_data_listview_widgets/import_json_data_dialog.dart';
import 'package:sachet/pages/settings_child_pages/view_data_page.dart';
import 'package:sachet/widgets/settingspage_widgets/settings_section_title.dart';

class CachedDataListviewPage extends StatefulWidget {
  const CachedDataListviewPage({super.key});

  @override
  State<CachedDataListviewPage> createState() => _CachedDataListviewPageState();
}

class _CachedDataListviewPageState extends State<CachedDataListviewPage> {
  List<FileSystemEntity> filesPathListQZ = [];
  List<FileSystemEntity> filesPathListExamTimeZF = [];

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

  Future importCachedData(
    BuildContext context,
    ColorScheme colorScheme,
    String folder, {
    List<String>? subFolder,
  }) async {
    // 使用 FilePicker 选择文件
    FilePickerResult? filePaths = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    String? filePath = filePaths?.files.first.path;

    if (!context.mounted) return;

    // 如果选择了一个文件
    if (filePaths?.isSinglePick == true && filePath != null) {
      File file = File(filePath);

      // 显示确认导入文件 Dialog
      String? result = await showDialog(
        context: context,
        builder: (BuildContext context) => ImportJsonDataDialog(file: file),
      );
      if (result != null) {
        // 写入缓存文件到 ApplicationSupportDirectory
        await CachedDataStorage().writeFileToAppSupportDir(
          fileName: result != ''
              ? '$result.json'
              : "file_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json",
          folder: folder,
          subFolder: subFolder,
          value: file.readAsStringSync(),
        );

        // 导入成功 SnackBar
        final snackBar = SnackBar(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
          content: Row(
            children: [
              Icon(Icons.done_outlined, color: colorScheme.onInverseSurface),
              const SizedBox(width: 20),
              Text(
                '导入成功',
                style: TextStyle(color: colorScheme.onInverseSurface),
              ),
            ],
          ),
        );

        if (!context.mounted) return;

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
    await CachedDataStorage()
        .lsByModifiedTime(AppFolder.cachedData.name)
        .then((value) {
      setState(() {
        filesPathListQZ = value;
      });
    });
    await CachedDataStorage().lsByModifiedTime(
      AppFolder.cachedDataZF.name,
      subFolders: [CachedDataZFSubFolder.examTimeCache.name],
    ).then((value) {
      setState(() {
        filesPathListExamTimeZF = value;
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("缓存数据查看"),
      ),
      body: ListView(
        children: [
          /// 强智教务系统的缓存
          _buildHeader('强智教务系统缓存 (${AppFolder.cachedData.name}/)'),
          ...filesPathListQZ.map((file) => _buildFileListTile(context, file)),
          _buildImportButton(context, colorScheme, AppFolder.cachedData.name),

          Divider(),

          /// 正方教务系统的缓存
          _buildHeader('正方教务系统缓存 (${AppFolder.cachedDataZF.name}/)'),
          _buildSubHeader(
            colorScheme,
            '考试时间 (${AppFolder.cachedDataZF.name}/${CachedDataZFSubFolder.examTimeCache.name}/)',
          ),
          ...filesPathListExamTimeZF
              .map((file) => _buildFileListTile(context, file)),
          _buildImportButton(
            context,
            colorScheme,
            AppFolder.cachedDataZF.name,
            subFolder: [CachedDataZFSubFolder.examTimeCache.name],
          )
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: SettingsSectionTitle(title: title),
    );
  }

  Widget _buildSubHeader(ColorScheme colorScheme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, color: colorScheme.primary),
      ),
    );
  }

  Widget _buildFileListTile(BuildContext context, FileSystemEntity file) {
    final String fileName = path.basename(file.path);
    final String displayName = fileNameToMeaning[fileName] ?? fileName;
    final String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(File(file.path).lastModifiedSync());

    return ListTile(
      title: Text(displayName, style: TextStyle(fontSize: 15)),
      subtitle: Text(
        '${file.path}'
        '\n'
        '更新时间: $modifiedTime',
        style: TextStyle(fontSize: 12),
      ),
      isThreeLine: true,
      trailing: Align(
        widthFactor: 1,
        alignment: Alignment.centerRight,
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              fadeTransitionPageRoute(ViewCachedDataPage(filePath: file.path)),
            ).then((result) => {result ? setState(() {}) : null});
          },
          icon: Icon(Icons.edit_note),
        ),
      ),
    );
  }

  Widget _buildImportButton(
    BuildContext context,
    ColorScheme colorScheme,
    String folder, {
    List<String>? subFolder,
  }) {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.file_open,
            size: 15,
            applyTextScaling: true,
          ),
          SizedBox(width: 4.0),
          Text(
            '导入数据',
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
      iconColor: colorScheme.primary,
      textColor: colorScheme.primary,
      onTap: () async {
        await importCachedData(
          context,
          colorScheme,
          folder,
          subFolder: subFolder,
        );
      },
    );
  }
}
