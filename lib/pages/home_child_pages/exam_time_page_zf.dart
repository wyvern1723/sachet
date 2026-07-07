import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/services/zhengfang_jwxt/exam_time/models/exam_time_response_zf.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/zhengfang_jwxt.dart';
import 'package:sachet/utils/export_to_ics.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/widgets/homepage_widgets/exam_time_page_zf_widgets/exam_time_card.dart';
import 'package:sachet/widgets/homepage_widgets/exam_time_page_zf_widgets/switch_exam_time_cached_data_dialog.dart';
import 'package:sachet/widgets/homepage_widgets/utils_widgets/change_semester_dialog.dart';
import 'package:sachet/widgets/utils_widgets/error_with_retry_widget.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/error_info_snackbar.dart';

import 'package:path/path.dart' as path;

class ExamTimePageZF extends StatefulWidget {
  /// 考试时间查询页面（正方教务）
  const ExamTimePageZF({super.key});

  @override
  State<ExamTimePageZF> createState() => _ExamTimePageZFState();
}

class _ExamTimePageZFState extends State<ExamTimePageZF> {
  late Future _future;

  Map semestersYears = {};
  final Map semesterIndexes = {"全部": "", "1": "3", "2": "12"};

  /// 当前查询的学年
  String _selectedSemesterYear = '';

  /// 当前查询的学期
  String _selectedSemesterIndex = '';

  // true => 显示详细信息, false => 显示精简信息
  bool _isDetailedView = false;

  List<ExamTimeResponseZF>? _examTimeData;

  /// 缓存的考试时间数据的文件路径
  String? _cachedDataFilePath;

  /// 缓存的考试时间数据
  List<ExamTimeResponseZF>? _examTimeDataCachedData;

  /// 缓存的考试时间的学期
  String? _cachedDataSemester;

  /// 缓存数据的上次修改时间
  String? _cachedDataLastModifiedTime;

  /// 是否正在查看缓存数据
  bool _isShowingCachedData = false;

  String get _displaySemesterYear => semestersYears.keys.firstWhere(
      (key) => semestersYears[key] == _selectedSemesterYear,
      orElse: () => _selectedSemesterYear);

  String get _displaySemesterIndex => semesterIndexes.keys.firstWhere(
      (key) => semesterIndexes[key] == _selectedSemesterIndex,
      orElse: () => _selectedSemesterIndex);

  Future _getSemestersData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await ZhengFangJwxt.examTime.getExamTimeSemesters(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );

    _selectedSemesterYear = result.currentSemesterYear ?? '';
    _selectedSemesterIndex = result.currentSemesterIndex ?? '';

    semestersYears = result.semestersYears;
  }

  Future _getExamTimeData(ZhengFangUserProvider? zhengFangUserProvider) async {
    try {
      if (semestersYears.isEmpty) {
        await _getSemestersData(zhengFangUserProvider);
      }

      final result = await ZhengFangJwxt.examTime.getExamTime(
        cookie: ZhengFangUserProvider.cookie,
        zhengFangUserProvider: zhengFangUserProvider,
        semesterYear: _selectedSemesterYear,
        semesterIndex: _selectedSemesterIndex,
      );

      // 缓存考试时间数据
      await _cacheExamTimeData(
          result, '$_displaySemesterYear-$_displaySemesterIndex');

      if (mounted) {
        setState(() {
          _isShowingCachedData = false;
          _examTimeData = result;
        });
      }

      return result;
    } catch (e) {
      try {
        final cacheData = await _getExamTimeCachedData();
        if (cacheData != null) {
          _examTimeDataCachedData = cacheData.data;
        }
      } catch (e) {
        if (kDebugMode) {
          print('读取考试时间缓存数据失败: $e');
        }
      }
      rethrow;
    }
  }

  void _onRetry() {
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    setState(() {
      _isShowingCachedData = false;
      _future = _getExamTimeData(zhengFangUserProvider);
    });
  }

  // 查看缓存的考试时间数据
  void _showExamTimeCachedData() {
    setState(() {
      _examTimeData = _examTimeDataCachedData;
      _isShowingCachedData = true;
      _future = Future.value(_examTimeDataCachedData);
    });
  }

  /// 缓存考试时间数据
  Future _cacheExamTimeData(
      List<ExamTimeResponseZF> examTimeData, String semester) async {
    List jsonData = [];
    for (final e in examTimeData) {
      jsonData.add(e.toJson());
    }
    String prettyJsonData = formatJsonEncode(jsonData);
    await CachedDataStorage().writeFileToAppSupportDir(
      fileName: 'exam_time_$semester.json',
      folder: AppFolder.cachedDataZF.name,
      subFolder: [CachedDataZFSubFolder.examTimeCache.name],
      value: prettyJsonData,
    );
  }

  /// 获取考试时间数据的缓存数据
  Future<({List<ExamTimeResponseZF> data, String lastModifiedTime})?>
      _getExamTimeCachedData({String? filePath}) async {
    String? cachedDataFilePath;

    /// 如果未指定读取的缓存数据路径，则从缓存数据的文件夹下寻找最新修改的文件作为要读取的文件
    if (filePath == null) {
      final List<FileSystemEntity> files = await CachedDataStorage()
          .lsByModifiedTime(AppFolder.cachedDataZF.name,
              subFolders: [CachedDataZFSubFolder.examTimeCache.name]);
      if (files.isEmpty) {
        return null;
      }
      final FileSystemEntity newestFile = files.first;
      cachedDataFilePath = newestFile.path;
    } else {
      cachedDataFilePath = filePath;
    }

    final String rawData =
        await CachedDataStorage().readDataViaFilePath(cachedDataFilePath);

    if (rawData == '') {
      return null;
    }

    _cachedDataFilePath = cachedDataFilePath;

    final data = jsonDecode(rawData);

    List<ExamTimeResponseZF> examTimeData = [];
    for (final e in data) {
      examTimeData.add(ExamTimeResponseZF.fromJson(e));
    }

    // 该文件的上次修改时间
    final lastModifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(File(cachedDataFilePath).lastModifiedSync());

    _cachedDataSemester = path
        .basenameWithoutExtension(cachedDataFilePath)
        .replaceAll('exam_time_', '');
    _cachedDataLastModifiedTime = lastModifiedTime;

    return (data: examTimeData, lastModifiedTime: lastModifiedTime);
  }

  Future _changeSemester(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChangeSemesterDialogZF(
        semestersYears: semestersYears,
        selectedSemesterYear: _selectedSemesterYear,
        selectedSemesterIndex: _selectedSemesterIndex,
      ),
    );

    if (!context.mounted) return;

    if (result != null && result is List) {
      _selectedSemesterYear = result[0];
      _selectedSemesterIndex = result[1];
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _examTimeData = null;
        _isShowingCachedData = false;
        _future = _getExamTimeData(zhengFangUserProvider);
      });
    }
  }

  /// 导出考试时间数据到 .ics 文件
  Future _exportExamTimeToIcs(BuildContext context) async {
    try {
      final semesterStr = _isShowingCachedData
          ? (_cachedDataSemester ?? '')
          : '$_displaySemesterYear-$_displaySemesterIndex';

      final filePath = await exportExamTimeToIcs(
        exams: _examTimeData!,
        savefileName: '考试安排_$semesterStr',
      );

      if (!context.mounted) return;

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
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(errorInfoSnackBar(context, '导出考试安排失败：$e'));
    }
  }

  Future _switchCachedData(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) =>
          SwitchExamTimeCachedDataDialog(activeFilePath: _cachedDataFilePath),
    );

    if (!context.mounted) return;

    if (result is String) {
      _cachedDataFilePath = result;

      try {
        final cacheData = await _getExamTimeCachedData(filePath: result);

        if (!context.mounted) return;

        if (cacheData != null) {
          _examTimeDataCachedData = cacheData.data;
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(errorInfoSnackBar(context, '读取缓存失败: $e'));

        return;
      }

      _showExamTimeCachedData();
    } else if (result == true) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _future = _getExamTimeData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('考试时间'),
        actions: [
          Selector<SettingsProvider, bool>(
            selector: (_, provider) => provider.isShowExamTimeCountdown,
            builder: (context, isShowCountDown, _) {
              return PopupMenuButton<void>(
                tooltip: '更多操作',
                itemBuilder: (context) {
                  return [
                    // 切换查询学期
                    PopupMenuItem(
                      onTap: () async {
                        await _changeSemester(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.history_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          const Text('切换查询学期'),
                        ],
                      ),
                    ),
                    if (_examTimeData != null && _examTimeData!.isNotEmpty) ...[
                      // 导出考试安排
                      PopupMenuItem(
                        onTap: () => _exportExamTimeToIcs(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.share_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            const Text('导出考试安排'),
                          ],
                        ),
                      ),
                      // 切换是否显示考试时间倒计时
                      PopupMenuItem(
                        onTap: () => context
                            .read<SettingsProvider>()
                            .toggleIsShowExamTimeCountdown(),
                        child: Row(
                          children: [
                            Icon(
                              isShowCountDown
                                  ? Icons.hourglass_disabled
                                  : Icons.hourglass_empty,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(isShowCountDown ? '隐藏倒计时' : '显示倒计时'),
                          ],
                        ),
                      ),
                      // 切换显示详细信息/显示精简信息
                      PopupMenuItem(
                        onTap: () {
                          setState(() => _isDetailedView = !_isDetailedView);
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isDetailedView
                                  ? Icons.notes_outlined
                                  : Icons.subject_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(_isDetailedView ? '显示精简信息' : '显示详细信息'),
                          ],
                        ),
                      ),
                    ],
                    // 查看缓存数据
                    PopupMenuItem(
                      onTap: () {
                        _switchCachedData(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            // Icons.cloud_off,
                            Icons.cloud_done_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          const Text('查看缓存数据'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        top: false,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              if (_examTimeDataCachedData != null) {
                final actions = [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Theme.of(context).useMaterial3
                            ? FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: _onRetry,
                                icon: Icon(
                                  Icons.refresh,
                                  size: 18,
                                  applyTextScaling: true,
                                ),
                                label: const Text('重试'),
                              )
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: _onRetry,
                                icon: Icon(
                                  Icons.refresh,
                                  size: 18,
                                  applyTextScaling: true,
                                ),
                                label: const Text('重试'),
                              ),
                        SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _showExamTimeCachedData,
                          icon: Icon(
                            Icons.storage_rounded,
                            size: 18,
                            applyTextScaling: true,
                          ),
                          label: const Text('查看缓存数据'),
                        ),
                      ],
                    ),
                  ),
                ];

                if (snapshot.error ==
                    "获取可查询学期数据失败: Http status code = 302, 可能需要重新登录") {
                  return _examTimeDataCachedData != null
                      ? LoginExpiredZF(actions: actions)
                      : LoginExpiredZF(onRetry: _onRetry);
                }

                return ErrorWithRetryWidget(
                  text: '${snapshot.error}',
                  actions: actions,
                  footer: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        '查询学期: $_displaySemesterYear-$_displaySemesterIndex',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                );
              } else {
                if (snapshot.error ==
                    "获取可查询学期数据失败: Http status code = 302, 可能需要重新登录") {
                  return LoginExpiredZF(onRetry: _onRetry);
                }

                return ErrorWithRetryWidget(
                  text: '${snapshot.error}',
                  onRetry: _onRetry,
                  footer: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        '查询学期: $_displaySemesterYear-$_displaySemesterIndex',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                );
              }
            }

            return _ExamTimeViewZF(
              examTimeData: _examTimeData,
              queryingSemester: _isShowingCachedData
                  ? _cachedDataSemester
                  : '$_displaySemesterYear-$_displaySemesterIndex',
              isDetailedView: _isDetailedView,
              isShowingCachedData: _isShowingCachedData,
              cachedDataLastModifiedTime: _cachedDataLastModifiedTime,
              onRefresh: _onRetry,
              onSwitchCachedData: () {
                _switchCachedData(context);
              },
            );
          },
        ),
      ),
    );
  }
}

/// 考试时间结果 View
class _ExamTimeViewZF extends StatelessWidget {
  const _ExamTimeViewZF({
    required this.examTimeData,
    this.queryingSemester,
    required this.isDetailedView,
    required this.isShowingCachedData,
    this.cachedDataLastModifiedTime,
    this.onRefresh,
    this.onSwitchCachedData,
  });
  final List<ExamTimeResponseZF>? examTimeData;
  final String? queryingSemester;
  final bool isDetailedView;
  final bool isShowingCachedData;
  final String? cachedDataLastModifiedTime;
  final VoidCallback? onRefresh;
  final VoidCallback? onSwitchCachedData;

  @override
  Widget build(BuildContext context) {
    final safeAreaInsets = MediaQuery.of(context).padding;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0 + safeAreaInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (examTimeData != null)
            ...examTimeData!.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ExamTimeCardZF(
                  examTime: e,
                  isDetailedView: isDetailedView,
                ),
              );
            }),
          SizedBox(height: 4),

          // Footer, 显示当前查询的学期
          if (!isShowingCachedData)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 8.0),
              child: Text(
                '查询学期: $queryingSemester',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          if (isShowingCachedData) _useCachedDataCard(colorScheme),
        ],
      ),
    );
  }

  Widget _useCachedDataCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      color: colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 8.0),
                Text(
                  '正在查看离线缓存数据',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              '查询学期: $queryingSemester'
              '\n'
              '更新时间: $cachedDataLastModifiedTime',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.comfortable,
                  ),
                  onPressed: onSwitchCachedData,
                  icon: Icon(
                    Icons.storage_rounded,
                    size: 14,
                    applyTextScaling: true,
                  ),
                  label: Text('查看所有缓存数据', style: TextStyle(fontSize: 10)),
                ),
                SizedBox(width: 4.0),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.comfortable,
                  ),
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh,
                    size: 14,
                    applyTextScaling: true,
                  ),
                  label: Text('重新加载', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
