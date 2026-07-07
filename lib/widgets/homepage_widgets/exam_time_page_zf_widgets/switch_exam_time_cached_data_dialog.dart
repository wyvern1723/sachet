import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class SwitchExamTimeCachedDataDialog extends StatefulWidget {
  /// 切换当前查看的考试时间的缓存数据的 Dialog（因为会缓存不同学期的考试时间数据，所以可以切换查看不同学期的考试时间数据）
  const SwitchExamTimeCachedDataDialog({
    super.key,
    required this.activeFilePath,
  });
  final String? activeFilePath;

  @override
  State<SwitchExamTimeCachedDataDialog> createState() =>
      _SwitchExamTimeCachedDataDialogState();
}

class _SwitchExamTimeCachedDataDialogState
    extends State<SwitchExamTimeCachedDataDialog> {
  List<FileSystemEntity> filesList = [];

  bool isModified = false;

  /// 获取缓存数据文件列表并刷新界面
  Future<void> _getFilesList() async {
    await CachedDataStorage().lsByModifiedTime(
      AppFolder.cachedDataZF.name,
      subFolders: [CachedDataZFSubFolder.examTimeCache.name],
    ).then((value) {
      setState(() {
        filesList = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getFilesList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('选择缓存数据'),
      clipBehavior: Clip.hardEdge,
      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 12),
      content: filesList.isEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
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
                Text('没有缓存数据'),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: filesList
                  .map(
                    (file) => RadioListTile(
                      value: file.path,
                      groupValue: widget.activeFilePath,
                      onChanged: (value) {
                        // 把选择的 filePath(value) 作为 result 从这个 Dialog 返回
                        Navigator.pop(context, value);
                      },
                      title: Text(
                          '学期: ${path.basenameWithoutExtension(file.path).replaceAll('exam_time_', '')}'),
                      subtitle: Text(
                        '更新时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(file.statSync().modified)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      selected: widget.activeFilePath == file.path,
                    ),
                  )
                  .toList(),
            ),
      actions: [
        filesList.isEmpty
            ? TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('确认'),
              )
            : TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
      ],
    );
  }
}
