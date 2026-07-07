import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';

class DeleteCachedDataDialog extends StatefulWidget {
  const DeleteCachedDataDialog({super.key});

  @override
  State<DeleteCachedDataDialog> createState() => _DeleteCachedDataDialogState();
}

class _DeleteCachedDataDialogState extends State<DeleteCachedDataDialog> {
  /// 是否删除 旧教务系统（强智教务系统）培养方案 的缓存数据
  bool _isDeleteCultivationQZ = false;

  /// 是否删除 旧教务系统（强智教务系统）考试时间 的缓存数据
  bool _isDeleteExamTimeQZ = false;

  /// 是否删除 新教务系统（正方教务系统）考试时间 的缓存数据
  bool _isDeleteExamTimeZF = false;

  /// 旧教务系统（强智教务系统）培养方案 的缓存数据的文件大小
  int? _cultivationQZFileSize;

  /// 旧教务系统（强智教务系统）考试时间 的缓存数据的文件大小
  int? _examTimeQZFileSize;

  /// 新教务系统（正方教务系统）考试时间 的缓存数据的文件数量
  int? _examTimeZFAmount;

  /// 新教务系统（正方教务系统）考试时间 的缓存数据的总文件大小
  int? _examTimeZFFileSize;

  /// 获取缓存数据信息
  Future _getCacheDataInfo() async {
    final int? cultivationQZFileSize =
        await _getCachedFile(AppFolder.cachedData.name, 'cultivate_plan.json');

    final int? examTimeQZFileSize =
        await _getCachedFile(AppFolder.cachedData.name, 'exam_time.json');

    final info = await _getCachedFiles(
      AppFolder.cachedDataZF.name,
      subFolders: [CachedDataZFSubFolder.examTimeCache.name],
    );

    final int examTimeZFAmount = info.amount;
    final int examTimeZFFileSize = info.totalSize;

    if (!mounted) return;

    setState(() {
      _cultivationQZFileSize = cultivationQZFileSize;
      _examTimeQZFileSize = examTimeQZFileSize;
      _examTimeZFAmount = examTimeZFAmount;
      _examTimeZFFileSize = examTimeZFFileSize;
    });
  }

  /// 获取单个缓存数据文件的信息，如果存在，返回此文件大小, 如果不存在，返回 null
  Future<int?> _getCachedFile(String folder, String fileName) async {
    final file = await CachedDataStorage.getFile(folder, fileName);
    final isExist = await file.exists();

    if (isExist) {
      final fileSize = await file.length();
      return fileSize;
    }
    return null;
  }

  /// 获取某个文件夹下所有缓存数据文件的信息，返回文件数量和文件总大小,
  Future<({int amount, int totalSize})> _getCachedFiles(String folder,
      {List<String>? subFolders}) async {
    final List<FileSystemEntity> files =
        await CachedDataStorage.ls(folder, subFolders: subFolders);

    if (files.isEmpty) {
      return (amount: 0, totalSize: 0);
    }
    int totalSize = 0;

    for (final file in files) {
      final fileStat = await file.stat();
      final fileSize = fileStat.size;
      totalSize = totalSize + fileSize;
    }

    return (amount: files.length, totalSize: totalSize);
  }

  @override
  void initState() {
    super.initState();
    _getCacheDataInfo();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('删除缓存数据'),
      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            enabled: _cultivationQZFileSize != null,
            value: _isDeleteCultivationQZ,
            title: Text('旧教务系统培养方案'),
            subtitle: Text(_cultivationQZFileSize == null
                ? '共0个文件, 0KB'
                : '共1个文件, ${((_cultivationQZFileSize ?? 0) / 1024).toStringAsFixed(2)} KB'),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _isDeleteCultivationQZ = value;
                });
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            enabled: _examTimeQZFileSize != null,
            value: _isDeleteExamTimeQZ,
            title: Text('旧教务系统考试时间'),
            subtitle: Text(_examTimeQZFileSize == null
                ? '共0个文件, 0KB'
                : '共1个文件, ${((_examTimeQZFileSize ?? 0) / 1024).toStringAsFixed(2)} KB'),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _isDeleteExamTimeQZ = value;
                });
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            enabled: _examTimeZFAmount != null && _examTimeZFAmount != 0,
            value: _isDeleteExamTimeZF,
            title: Text('新教务系统考试时间'),
            subtitle: Text(_examTimeZFAmount == null
                ? '共0个文件, 0KB'
                : '共$_examTimeZFAmount个文件, ${((_examTimeZFFileSize ?? 0) / 1024).toStringAsFixed(2)} KB'),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _isDeleteExamTimeZF = value;
                });
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            if (_isDeleteCultivationQZ) {
              await CachedDataStorage.deleteCachedData(
                  AppFolder.cachedData.name, 'cultivate_plan.json');
            }

            if (_isDeleteExamTimeQZ) {
              await CachedDataStorage.deleteCachedData(
                  AppFolder.cachedData.name, 'exam_time.json');
            }

            if (_isDeleteExamTimeZF) {
              await CachedDataStorage.deleteCachedExamTimeZF();
            }

            if (!context.mounted) return;

            // 如果删除任意一项，返回 true
            if (_isDeleteCultivationQZ ||
                _isDeleteExamTimeQZ ||
                _isDeleteExamTimeZF) {
              Navigator.pop(context, true);
            } else {
              // 什么都没删除还是点了确认
              Navigator.pop(context);
            }
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}
