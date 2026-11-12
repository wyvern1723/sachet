import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/pages/class_child_pages/course_settings_page.dart';
import 'package:sachet/pages/settings_child_pages/view_data_page.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/semester_utils.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/widgets/classpage_widgets/rename_app_file_dialog.dart';
import 'package:sachet/widgets/utils_widgets/section_card.dart';

/// 课表操作 BottomSheet 需要在关闭后继续执行的操作
enum ClassScheduleAction {
  /// 获取/更新课表
  updateClassSchedule,

  /// 导出课表
  exportClassSchedule,
}

class ClassScheduleActionsBottomSheet extends StatefulWidget {
  const ClassScheduleActionsBottomSheet({
    super.key,
    required this.classPageProvider,
  });

  final ClassPageProvider classPageProvider;

  @override
  State<ClassScheduleActionsBottomSheet> createState() =>
      _ClassScheduleActionsBottomSheetState();
}

class _ClassScheduleActionsBottomSheetState
    extends State<ClassScheduleActionsBottomSheet> {
  /// 是否在学期列表打开了学期
  bool _isOpenSemester = false;

  /// 从学期列表打开的学期
  String _openedSemester = '';

  /// 课程表文件列表
  List<FileSystemEntity> fileEntityList = [];

  /// 无法从文件名解析出学期的课表文件归到此类
  static const String _unknownSemester = '无法识别学期';

  /// 从课程表文件路径提取该课程表文件的学期，如果提取失败，返回 [_unknownSemester]
  String _semesterOf(String filePath) {
    return semesterFromFileName(filePath) ?? _unknownSemester;
  }

  /// 当前所有课程表文件包括的学期（从新到旧，「无法识别学期」排在最后）
  List<String> _semesterNames() {
    final Set<String> semesterSet = {};
    for (final e in fileEntityList) {
      semesterSet.add(_semesterOf(e.path));
    }
    final List<String> semesters = semesterSet.toList()
      ..sort((a, b) => b.compareTo(a));
    if (semesters.remove(_unknownSemester)) {
      semesters.add(_unknownSemester);
    }
    return semesters;
  }

  /// 获取课程表数据文件列表并刷新界面
  Future<void> _getFilesList() async {
    await CachedDataStorage.lsByModifiedTime(AppFolder.classSchedule.name)
        .then((value) {
      setState(() {
        fileEntityList = value;
      });
    });
  }

  List<String> _filesOf(String semester) {
    List<String> filePathList = [];
    for (final e in fileEntityList) {
      final filePath = e.path;
      if (_semesterOf(filePath) == semester) {
        filePathList.add(filePath);
      }
    }
    return filePathList;
  }

  /// 切换当前使用的课程表文件
  ///
  /// -[semester] 此课程表的学期
  /// -[filePath] 此课程表文件路径
  Future<void> _switchClassScheduleFile(
    String semester,
    String filePath,
  ) async {
    final SettingsProvider settingsProvider = context.read<SettingsProvider>();
    final String currentSemester =
        settingsProvider.classScheduleFilePath.isEmpty
            ? ''
            : _semesterOf(settingsProvider.classScheduleFilePath);

    settingsProvider.setClassScheduleFilePath(filePath);

    // 课程表的学期开始日期由当前课表文件所在的学期决定，切换文件后需要刷新月份列表
    widget.classPageProvider.updateMonthList();

    // 如果更换到其他学期的课程表，同时修改当前配色方案为选择的课程表的学期的配色方案
    if (semester != currentSemester && semester != _unknownSemester) {
      final List<FileSystemEntity> colorFiles =
          await CachedDataStorage.lsByModifiedTime(AppFolder.courseColor.name);
      for (final colorFile in colorFiles) {
        final RegExpMatch? match = RegExp(r'\d{4}-\d{4}-\d+')
            .firstMatch(path.basenameWithoutExtension(colorFile.path));
        if (match?.group(0) == semester) {
          await settingsProvider.setCourseColorFilePath(colorFile.path);
          break;
        }
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  /// 长按学期修改该学期的开始日期
  Future<void> _editSemesterStartDate(String semester) async {
    if (semester == _unknownSemester) return;

    final DateTime? currentStartDate =
        SettingsProvider.semesterStartDateOf(semester);

    if (semesterToStartDate.containsKey(semester)) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('修改学期开始日期'),
          content: Text(
            '应用内置了 $semester 的学期开始日期'
            '（${DateFormat('yyyy-MM-dd').format(semesterToStartDate[semester]!)}），'
            '数据应该是准确的，确定要继续修改吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('继续修改'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('zh', 'CN'),
      initialDate: currentStartDate ?? constSemesterStartDate,
      firstDate: DateTime(1958, 6),
      lastDate: DateTime(2077, 12),
      selectableDayPredicate: (DateTime val) => val.weekday == 1,
      helpText: '选择学期开始日期',
    );
    if (picked == null || !mounted) return;

    final SettingsProvider settingsProvider = context.read<SettingsProvider>();
    settingsProvider.setSemesterStartDateOf(semester, picked);

    // 如果修改的是当前正在使用的课表所在学期，刷新课表的月份列表
    if (SettingsProvider.classScheduleSemester == semester) {
      widget.classPageProvider.updateMonthList();
    }

    setState(() {});
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

  @override
  void initState() {
    super.initState();
    _getFilesList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final safeAreaInsets = MediaQuery.of(context).padding;
    final String classScheduleFilePath =
        context.read<SettingsProvider>().classScheduleFilePath;
    final String currentSemester =
        classScheduleFilePath.isEmpty ? '' : _semesterOf(classScheduleFilePath);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Flexible(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, 0, 0, safeAreaInsets.bottom + 20),
              child: _isOpenSemester == false
                  ? _semestersList(
                      context,
                      colorScheme,
                      textTheme,
                      currentSemester,
                    )
                  : _filesList(
                      semester: _openedSemester,
                      classScheduleFilePath: classScheduleFilePath,
                      colorScheme,
                      textTheme,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _semestersList(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String currentSemester,
  ) {
    final List<String> semesters = _semesterNames();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              title: '切换课表',
              children: semesters.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            '没有找到课程表文件',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ]
                  : semesters
                      .map((semester) => _semesterListTile(
                            colorScheme,
                            textTheme,
                            semester: semester,
                            semesterStartDate:
                                SettingsProvider.semesterStartDateOf(semester),
                            isActive: currentSemester == semester,
                          ))
                      .toList(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _card(
                        colorScheme,
                        textTheme,
                        title: '获取/更新 课程表',
                        iconData: Icons.refresh,
                        onTap: () {
                          Navigator.pop(
                              context, ClassScheduleAction.updateClassSchedule);
                        },
                      ),
                    ),
                    Expanded(
                      child: _card(
                        colorScheme,
                        textTheme,
                        title: '导出课表',
                        iconData: Icons.share_outlined,
                        onTap: () {
                          Navigator.pop(
                              context, ClassScheduleAction.exportClassSchedule);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: _card(
                      colorScheme,
                      textTheme,
                      title: '课表设置',
                      iconData: Icons.tune_outlined,
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            maintainState: false,
                            builder: (context) => const CourseSettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _semesterListTile(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required String semester,
    required DateTime? semesterStartDate,
    bool isActive = false,
  }) {
    final int fileCount = _filesOf(semester).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        onTap: () {
          setState(() {
            _openedSemester = semester;
            _isOpenSemester = true;
          });
        },
        onLongPress: () => _editSemesterStartDate(semester),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: isActive
            ? Icon(Icons.done, color: Colors.green)
            : Icon(
                semester == _unknownSemester
                    ? Icons.folder_outlined
                    : Icons.school_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
                applyTextScaling: true,
              ),
        title: Text(semester, style: textTheme.bodyLarge),
        subtitle: Text(
          semester == _unknownSemester
              ? '$fileCount 个文件'
              : '学期开始日期: ${semesterStartDate == null ? '?' : DateFormat('yyyy-MM-dd').format(semesterStartDate)} · $fileCount 个文件',
        ),
        trailing: Icon(
          // Icons.arrow_forward,
          Icons.chevron_right,
          // color: colorScheme.onSurfaceVariant,
          color: colorScheme.outline,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _card(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required String title,
    required IconData iconData,
    VoidCallback? onTap,
  }) {
    return Card(
      shadowColor: colorScheme.primaryContainer.withOpacity(0.4),
      clipBehavior: Clip.hardEdge,
      // color: colorScheme.surfaceContainerHighest.withAlpha(150),
      // color: colorScheme.secondaryContainer.withAlpha(150),
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 4,
            children: [
              Icon(
                iconData,
                color: colorScheme.primary,
                applyTextScaling: true,
                size: 20,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSecondaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filesList(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required String semester,
    required String classScheduleFilePath,
  }) {
    final filePaths = _filesOf(semester);

    return SectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _isOpenSemester = false);
                },
                icon: const Icon(Icons.arrow_back),
                tooltip: '返回学期列表',
                visualDensity: VisualDensity.compact,
              ),
              Expanded(child: Text(semester, style: textTheme.titleMedium)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (filePaths.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                '该学期还没有课表文件',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...filePaths.map(
            (filePath) => _fileListTile(
              filePath,
              semester,
              filePath == classScheduleFilePath,
              colorScheme,
              textTheme,
            ),
          ),
      ],
    );
  }

  Widget _fileListTile(
    String filePath,
    String semester,
    bool isActive,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final Color onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        visualDensity: VisualDensity.compact,
        onTap: () {
          _switchClassScheduleFile(semester, filePath);
        },
        title: Text(
            path
                .basenameWithoutExtension(filePath)
                .replaceAll('class_schedule_', ''),
            style: textTheme.bodyLarge),
        subtitle: Text(
          '更新时间: ${DateFormat('yyyy年MM月dd日 HH:mm:ss').format(File(filePath).lastModifiedSync())}'
          '\n'
          '文件大小: ${(File(filePath).lengthSync() / 1024).toStringAsFixed(2)}KB',
        ),
        subtitleTextStyle: textTheme.bodySmall,
        trailing: isActive == true
            // 因为 Icon 和 PopupMenuButton 在水平方向没对齐，所以使用一个不能点击 IconButton 代替 Icon 以实现对齐
            // ? Icon(Icons.done, color: Colors.green)
            ? IconButton(
                onPressed: null,
                icon: Icon(Icons.done, color: Colors.green),
              )
            : PopupMenuButton(
                menuPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(children: [
                      Icon(Icons.check, color: onSurfaceVariant),
                      const SizedBox(width: 8),
                      const Text('使用'),
                    ]),
                    onTap: () {
                      _switchClassScheduleFile(semester, filePath);
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
                            filePath: filePath,
                            isReadOnly: true,
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuItem(
                    onTap: () {
                      _deleteFile(filePath);
                    },
                    child: Row(children: [
                      Icon(Icons.delete_forever, color: onSurfaceVariant),
                      const SizedBox(width: 8),
                      const Text('删除'),
                    ]),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      _renameFile(filePath);
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
    );
  }
}
