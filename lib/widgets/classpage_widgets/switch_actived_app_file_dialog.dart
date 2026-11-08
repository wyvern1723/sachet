import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sachet/pages/settings_child_pages/view_data_page.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/widgets/classpage_widgets/rename_app_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

/// 切换使用的文件的 Dialog(切换课表文件，切换配色方案)
class SwitchActivedAppFileDialog extends StatefulWidget {
  const SwitchActivedAppFileDialog({
    super.key,
    required this.dialogTitle,
    required this.fileDirectory,
    required this.settingsFilePath,
  });
  final String dialogTitle;
  final String fileDirectory;
  final String settingsFilePath;

  @override
  State<SwitchActivedAppFileDialog> createState() =>
      _SwitchActivedAppFileDialogState();
}

class _SwitchActivedAppFileDialogState
    extends State<SwitchActivedAppFileDialog> {
  List<FileSystemEntity> filesPathList = [];

  /// 获取课程表数据文件列表并刷新界面
  Future<void> _getFilesList() async {
    await CachedDataStorage.lsByModifiedTime(widget.fileDirectory)
        .then((value) {
      setState(() {
        filesPathList = value;
      });
    });
  }

  void _deleteFile(String filePath) async {
    var result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('删除'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('确定要删除该文件?'),
                  Text('> ${path.basename(filePath)}'),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('取消')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text('删除')),
              ],
            ));
    if (result == true) {
      await File(filePath).delete();
      _getFilesList();
    }
  }

  void _renameFile(String filePath) async {
    String fileName = path.basenameWithoutExtension(filePath);
    var newName = await showDialog(
        context: context,
        builder: (context) => RenameAppFileDialog(fileName: fileName));
    if (newName != null) {
      var newPath = filePath.replaceAll(fileName, newName);
      await File(filePath).rename(newPath);
      _getFilesList();
    }
  }

  void _switchActiveFile(String value) {
    // 把选择的 filePath(value) 作为 result 从这个 Dialog 返回
    Navigator.pop(context, value);
  }

  @override
  void initState() {
    super.initState();
    _getFilesList();
  }

  @override
  Widget build(BuildContext context) {
    final Color onSurfaceVariant =
        Theme.of(context).colorScheme.onSurfaceVariant;

    return SimpleDialog(
      title: Text(widget.dialogTitle),
      clipBehavior: Clip.hardEdge, // 如果不设置，长按的水波效果会超出 dialog
      children: filesPathList.isEmpty
          ? [
              Column(
                children: [
                  // ¯\_(ツ)_/¯
                  // ∑(￣□￣;)
                  // (つд⊂)
                  // (´･_･`)
                  Text(
                    "¯\\_(ツ)_/¯",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  Text('没有找到数据'),
                ],
              )
            ]
          : List.generate(
              filesPathList.length,
              (int index) => RadioListTile(
                value: filesPathList[index].path,
                groupValue: widget.settingsFilePath,
                onChanged: (value) {
                  if (value != null) {
                    _switchActiveFile(value);
                  }
                },
                title: Text(path.basename(filesPathList[index].path)),
                subtitle: Text(
                  '更新时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(File(filesPathList[index].path).lastModifiedSync())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isThreeLine: true,
                selected: widget.settingsFilePath == filesPathList[index].path,
                secondary: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(children: [
                        Icon(Icons.check, color: onSurfaceVariant),
                        const SizedBox(width: 8),
                        const Text('使用'),
                      ]),
                      onTap: () {
                        final value = filesPathList[index].path;
                        _switchActiveFile(value);
                      },
                    ),
                    PopupMenuItem(
                      child: Row(children: [
                        Icon(Icons.visibility, color: onSurfaceVariant),
                        const SizedBox(width: 8),
                        const Text('查看'),
                      ]),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          fadeTransitionPageRoute(
                            ViewCachedDataPage(
                              filePath: filesPathList[index].path,
                              isReadOnly: true,
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.settingsFilePath !=
                        filesPathList[index].path) // 如果现在使用这个文件，不显示删除功能
                      PopupMenuItem(
                        onTap: () {
                          _deleteFile(filesPathList[index].path);
                        },
                        child: Row(children: [
                          Icon(Icons.delete_forever, color: onSurfaceVariant),
                          const SizedBox(width: 8),
                          const Text('删除'),
                        ]),
                      ),
                    if (widget.settingsFilePath !=
                        filesPathList[index].path) // 如果现在使用这个文件，不显示重命名功能
                      PopupMenuItem(
                        onTap: () {
                          _renameFile(filesPathList[index].path);
                        },
                        child: Row(children: [
                          Icon(Icons.drive_file_rename_outline_sharp,
                              color: onSurfaceVariant),
                          const SizedBox(width: 8),
                          const Text('重命名'),
                        ]),
                      ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.close, color: onSurfaceVariant),
                          const SizedBox(width: 8),
                          const Text('取消'),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
