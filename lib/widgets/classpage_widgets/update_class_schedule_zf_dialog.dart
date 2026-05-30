import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/enums/update_class_schedule_state.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/zhengfang_jwxt.dart';
import 'package:sachet/utils/utils_functions.dart';
import 'package:sachet/widgets/utils_widgets/error_with_retry_widget.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class UpdateClassScheduleZFDialog extends StatefulWidget {
  /// 更新课程表数据（从正方教务系统） Dialog
  const UpdateClassScheduleZFDialog({super.key});

  @override
  State<UpdateClassScheduleZFDialog> createState() =>
      _UpdateClassScheduleZFDialogState();
}

class _UpdateClassScheduleZFDialogState
    extends State<UpdateClassScheduleZFDialog> {
  UpdateClassScheduleState currentState =
      UpdateClassScheduleState.gettingSemester;
  Map semestersYears = {};
  String? _selectedSemesterYear;
  Map semesterIndexes = {"1": "3", "2": "12"};
  String? _selectedSemesterIndex;

  /// 是否在 学年 DropDownMenu 显示 ErrorTexy
  bool _isShowSemesterYearDropDownMenuError = false;

  /// 是否在 学期 DropDownMenu 显示 ErrorTexy
  bool _isShowSemesterIndexDropDownMenuError = false;

  /// 更新课表失败原因
  String _updateClassScheduleFailedErrorMsg = '';

  /// 获取学期失败原因
  String _getSemestesrFailedErrorMsg = '';

  /// 获取可选择学期和当前学期数据
  Future _getSemesters(ZhengFangUserProvider? zhengFangUserProvider) async {
    try {
      final result =
          await ZhengFangJwxt.classSchedule.getClassScheduleSemesters(
        cookie: ZhengFangUserProvider.cookie,
        zhengFangUserProvider: zhengFangUserProvider,
      );
      _selectedSemesterYear = result.$1;
      semestersYears = result.$2;
      _selectedSemesterIndex = result.$3;
      setState(() {
        currentState = UpdateClassScheduleState.selectSemester;
      });
    } catch (e) {
      if (e == '获取课表学期数据失败: Http status code = 302, 可能需要重新登录') {
        setState(() {
          currentState = UpdateClassScheduleState.loginExpired;
        });
      } else {
        if (kDebugMode) {
          print(e);
        }
        _getSemestesrFailedErrorMsg = e.toString();
        setState(() {
          currentState = UpdateClassScheduleState.getSemestersFailed;
        });
      }
    }
  }

  Future _updateClassSchedule(BuildContext context) async {
    if (_selectedSemesterYear == null || _selectedSemesterIndex == null) {
      setState(() {
        _isShowSemesterYearDropDownMenuError = (_selectedSemesterYear == null);
        _isShowSemesterIndexDropDownMenuError =
            (_selectedSemesterIndex == null);
      });
    } else {
      setState(() {
        currentState = UpdateClassScheduleState.updating;
      });
      try {
        final result = await ZhengFangJwxt.classSchedule.getClassSchedule(
          cookie: ZhengFangUserProvider.cookie,
          semesterYear: _selectedSemesterYear!,
          semesterIndex: _selectedSemesterIndex!,
        );

        if (!context.mounted) return;

        // 修改当前课程表文件
        context.read<SettingsProvider>().setClassScheduleFilePath(result[0]);

        // 修改当前课程对应的配色文件
        await context
            .read<SettingsProvider>()
            .setCourseColorFilePath(result[1]);
      } catch (e) {
        if (!context.mounted) return;

        if (kDebugMode) {
          print(e);
        }
        if (e == '获取课表数据失败: Http status code = 901, 验证身份信息失败') {
          setState(() {
            currentState = UpdateClassScheduleState.loginExpired;
          });
        } else {
          _updateClassScheduleFailedErrorMsg = e.toString();
          setState(() {
            currentState = UpdateClassScheduleState.updateClassScheduleFailed;
          });
        }
        return;
      }

      // 获取开学日期
      try {
        // 如果从教务系统获取当前开学日期成功，更改默认开学日期
        final result = await ZhengFangJwxt.classSchedule
            .getSemesterStartDate(cookie: ZhengFangUserProvider.cookie);

        if (!context.mounted) return;

        context.read<SettingsProvider>().setSemesterStartDate(result.$1);
      } catch (e) {
        // 如果从教务系统获取当前开学日期失败，则保持使用预设的默认开学日期(constSemesterStartDate)
        if (kDebugMode) {
          print(e);
        }
      }

      if (!context.mounted) return;

      // 当前状态切换为用户手动设置(调整,如有必要)开学日期
      setState(() {
        currentState = UpdateClassScheduleState.setSemesterStartDate;
      });
    }
  }

  void _onRetry() {
    setState(() {
      currentState = UpdateClassScheduleState.gettingSemester;
    });
    _getSemesters(null);
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _getSemesters(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Brightness brightness = Theme.of(context).brightness;

    switch (currentState) {
      case UpdateClassScheduleState.gettingSemester:
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在获取学期'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      case UpdateClassScheduleState.selectSemester: // 选择学期
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 20,
                child: DropdownMenu<String>(
                  menuHeight: 400,
                  errorText:
                      _isShowSemesterYearDropDownMenuError ? "请选择一项" : null,
                  initialSelection: _selectedSemesterYear,
                  requestFocusOnTap: false,
                  label: const Text('学年'),
                  onSelected: (String? semester) {
                    if (semester != null) {
                      _selectedSemesterYear = semester;
                      if (_isShowSemesterYearDropDownMenuError == true) {
                        setState(() {
                          _isShowSemesterYearDropDownMenuError = false;
                        });
                      }
                    }
                  },
                  dropdownMenuEntries: semestersYears.entries
                      .map((e) => DropdownMenuEntry<String>(
                          value: e.value, label: e.key))
                      .toList(),
                ),
              ),
              Flexible(
                flex: 13,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: DropdownMenu<String>(
                    menuHeight: 400,
                    errorText:
                        _isShowSemesterIndexDropDownMenuError ? "请选择一项" : null,
                    initialSelection: _selectedSemesterIndex,
                    requestFocusOnTap: false,
                    label: const Text('学期'),
                    onSelected: (String? semester) {
                      if (semester != null) {
                        _selectedSemesterIndex = semester;
                        if (_isShowSemesterIndexDropDownMenuError == true) {
                          setState(() {
                            _isShowSemesterIndexDropDownMenuError = false;
                          });
                        }
                      }
                    },
                    dropdownMenuEntries: semesterIndexes.entries
                        .map((e) => DropdownMenuEntry<String>(
                            value: e.value, label: e.key))
                        .toList(),
                  ),
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
              onPressed: () async {
                await _updateClassSchedule(context);
              },
              child: const Text('确认'),
            )
          ],
        );
      case UpdateClassScheduleState.updating: // 获取课表中
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在更新课程表'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      case UpdateClassScheduleState.setSemesterStartDate: // 设置学期开始日期
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('成功获取课表数据，', style: textTheme.bodyMedium),
              Text('请选择学期开始日期：', style: textTheme.bodyLarge),
              SizedBox(height: 10),
              Text(
                '⚠️注意：请选择预备周（第一周）的周一，而不是第一天开始上课的日期（正式开始上课是第二周）',
                style: textTheme.bodySmall,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('参考：', style: textTheme.bodySmall),
                  GestureDetector(
                    onTap: () {
                      openLink(xtuSchoolCalendarUrl);
                    },
                    onLongPress: () => copyToClipboard(
                      context,
                      xtuSchoolCalendarUrl,
                      prefix: '链接',
                    ),
                    child: Text(
                      '校历',
                      style: TextStyle(
                        color: brightness == Brightness.light
                            ? Color(0xFF0645AD)
                            : Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: brightness == Brightness.light
                            ? const Color(0xFF0645AD)
                            : Colors.blue,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  labelText: '开学日期',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Selector<SettingsProvider, String>(
                        selector: (_, settingsProvider) =>
                            SettingsProvider.semesterStartDate,
                        builder: (_, semesterStartDate, __) {
                          return Text(
                            DateFormat('yyyy-MM-dd').format(
                                DateTime.tryParse(semesterStartDate) ??
                                    constSemesterStartDate),
                            style: textTheme.bodyLarge,
                          );
                        }),
                    IconButton(
                      onPressed: () async {
                        await selectSemesterStartDate(context);
                      },
                      icon: Icon(
                        Icons.edit_calendar_outlined,
                        // color: Theme.of(context).colorScheme.onSurfaceVariant,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true);
              },
              child: const Text('确认'),
            )
          ],
        );
      case UpdateClassScheduleState.loginExpired: // 登录失效（登录过期）
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24, 4, 24, 2),
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginExpiredZF.compact(onRetry: _onRetry),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确认'),
            )
          ],
        );
      case UpdateClassScheduleState.getSemestersFailed: // 获取可选学期失败
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24, 4, 24, 2),
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('获取可选学期失败:'),
              SizedBox(height: 4),
              ErrorWithRetryWidget.compact(text: _getSemestesrFailedErrorMsg)
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  currentState = UpdateClassScheduleState.gettingSemester;
                });
                await _getSemesters(null);
              },
              child: const Text('重试'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确认'),
            )
          ],
        );
      case UpdateClassScheduleState.updateClassScheduleFailed: // 更新课程表失败
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('更新失败:'),
              SizedBox(height: 4),
              Text(_updateClassScheduleFailedErrorMsg),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  currentState = UpdateClassScheduleState.selectSemester;
                });
              },
              child: const Text('重选学期'),
            ),
            TextButton(
              onPressed: () async {
                await _updateClassSchedule(context);
              },
              child: const Text('重试'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确认'),
            )
          ],
        );
    }
  }
}
