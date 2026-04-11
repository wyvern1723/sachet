import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/export_to_ics.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/error_info_snackbar.dart';

import 'package:path/path.dart' as path;

class ExportClassScheduleDialog extends StatefulWidget {
  /// 导出课程表 Dialog
  const ExportClassScheduleDialog({super.key});

  @override
  State<ExportClassScheduleDialog> createState() =>
      _ExportClassScheduleDialogState();
}

class _ExportClassScheduleDialogState extends State<ExportClassScheduleDialog> {
  List<FileSystemEntity> _filesPathList = [];

  /// 选中的课程表文件路径
  String? _selectedFilePath;

  /// 当前 App 使用的课程表文件路径
  String _currentFilePath = '';

  DateTime _currentSemesterStartDate =
      DateTime.tryParse(SettingsProvider.semesterStartDate) ??
          constSemesterStartDate;

  Future<void> _getClassScheduleFileList() async {
    String classScheduleFilePath =
        context.read<SettingsProvider>().classScheduleFilePath;
    _currentFilePath = classScheduleFilePath;

    if (classScheduleFilePath.isEmpty) {
      _selectedFilePath = null;
    }

    final List<FileSystemEntity> files = await CachedDataStorage()
        .lsByModifiedTime(AppFolder.classSchedule.name);

    setState(() {
      _filesPathList = files;
      _selectedFilePath = classScheduleFilePath;
    });
  }

  Future _exportToIcs(BuildContext context) async {
    try {
      final filePath = await exportClassScheduleToIcs(
        rawfilePath: _selectedFilePath!,
        savefileName: path.basenameWithoutExtension(_selectedFilePath!),
        semesterStartDate: _currentSemesterStartDate,
      );

      if (!context.mounted) {
        return;
      }
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.done, color: Colors.green),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    '成功导出到: $filePath',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(errorInfoSnackBar(context, e.toString()));
    }
  }

  /// 设置导出为 .ics 时使用的开学日期
  Future _updateSemesterStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('zh', 'CN'),
      initialDate: _currentSemesterStartDate,
      firstDate: DateTime(1958, 6),
      lastDate: DateTime(2077, 12),
      selectableDayPredicate: (DateTime val) => val.weekday == 1 ? true : false,
      helpText: '选择学期开始日期（第一周/预备周 周一）',
    );

    if (!context.mounted) return;

    if (picked != null) {
      setState(() => _currentSemesterStartDate = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    _getClassScheduleFileList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text('导出课表到 .ics 日历文件'),
      titleTextStyle: textTheme.titleLarge,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownMenu<String>(
            width: double.infinity,
            menuHeight: 400,
            initialSelection: _selectedFilePath,
            requestFocusOnTap: false,
            label: const Text('课程表数据文件'),
            onSelected: (String? filePath) {
              if (filePath != null) {
                setState(() => _selectedFilePath = filePath);
              }
            },
            dropdownMenuEntries: _filesPathList
                .map((e) => DropdownMenuEntry<String>(
                    value: e.path,
                    label:
                        '${path.basename(e.path)}${_currentFilePath == e.path ? ' (当前)' : ''}'))
                .toList(),
          ),
          SizedBox(height: 12),
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              labelText: '学期开始日期（第一周/预备周 周一）',
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(_currentSemesterStartDate),
                  style: textTheme.bodyLarge,
                ),
                IconButton(
                  onPressed: () async {
                    await _updateSemesterStartDate(context);
                  },
                  icon: Icon(
                    Icons.edit_calendar_outlined,
                    // color: colorScheme.onSurfaceVariant,
                    color: colorScheme.onSurface,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 24.0),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed:
              _selectedFilePath == null ? null : () => _exportToIcs(context),
          child: const Text('导出'),
        )
      ],
    );
  }
}
