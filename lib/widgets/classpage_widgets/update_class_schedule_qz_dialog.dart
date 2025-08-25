import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/update_class_schedule_state.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/get_class_schedule.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/get_class_shedule_semesters.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_qz.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateClassScheduleQZDialog extends StatefulWidget {
  /// 从强智教务系统更新课表的 Dialog
  const UpdateClassScheduleQZDialog({super.key});

  @override
  State<UpdateClassScheduleQZDialog> createState() =>
      _UpdateClassScheduleQZDialogState();
}

class _UpdateClassScheduleQZDialogState
    extends State<UpdateClassScheduleQZDialog> {
  UpdateClassScheduleState currentState =
      UpdateClassScheduleState.gettingSemester;
  Map semesters = {};
  String selectedSemester = '';

  /// 更新课表失败原因
  String _updateClassScheduleFailedErrorMsg = '';

  /// 获取学期失败原因
  String _getSemestesrFailedErrorMsg = '';

  /// 获取可选择学期和当前学期数据
  Future _getSemesters() async {
    await getClassScheduleSemestersDataQZ().then(
      (result) {
        if (!mounted) {
          return;
        }
        selectedSemester = result[0];
        semesters = result[1];
        setState(() {
          currentState = UpdateClassScheduleState.selectSemester;
        });
      },
      onError: (e) {
        if (!mounted) {
          return;
        }
        if (e == '登录失效，请重新登录') {
          setState(() {
            currentState = UpdateClassScheduleState.loginExpired;
          });
        } else {
          _getSemestesrFailedErrorMsg = e.toString();
          setState(() {
            currentState = UpdateClassScheduleState.getSemestersFailed;
          });
        }
      },
    );
  }

  Future _updateClassSchedule(BuildContext context) async {
    setState(() {
      currentState = UpdateClassScheduleState.updating;
    });
    await getClassScheduleDataQZ(selectedSemester).then(
      (pathList) async {
        if (!mounted) {
          // 如果取消，不保存
          // TODO: 只是没有保存和应用获取到的课表数据，实际上后台还是在获取课表。
          return;
        }
        // 修改当前课程表文件
        context.read<SettingsProvider>().setClassScheduleFilePath(pathList[0]);
        // 修改当前课程对应的配色文件
        await context
            .read<SettingsProvider>()
            .setCourseColorFilePath(pathList[1]);
        setState(() {
          currentState = UpdateClassScheduleState.setSemesterStartDate;
        });
      },
      onError: (e) {
        if (!mounted) {
          return;
        }
        if (e == '登录失效，请重新登录') {
          setState(() {
            currentState = UpdateClassScheduleState.loginExpired;
          });
        } else {
          _updateClassScheduleFailedErrorMsg = e.toString();
          setState(() {
            currentState = UpdateClassScheduleState.updateClassScheduleFailed;
          });
        }
      },
    );
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      _getSemesters();
    }
  }

  @override
  void initState() {
    super.initState();
    _getSemesters();
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
          ],
        );
      case UpdateClassScheduleState.selectSemester: // 选择学期
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              DropdownMenu<String>(
                menuHeight: 400,
                initialSelection: selectedSemester,
                requestFocusOnTap: false,
                label: const Text('学期'),
                onSelected: (String? semester) {
                  if (semester != null) {
                    selectedSemester = semester;
                  }
                },
                dropdownMenuEntries: semesters.entries
                    .map((e) => DropdownMenuEntry<String>(
                          value: e.value,
                          label: e.key,
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
          ],
        );
      // case UpdateState.success: // 获取课表完成
      //   return AlertDialog(
      //     title: const Text('更新课程表'),
      //     content: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         SizedBox(height: 10),
      //         Text('更新完成！'),
      //       ],
      //     ),
      //     actions: [
      //       TextButton(
      //         onPressed: () async {
      //           Navigator.pop(context);
      //         },
      //         child: const Text('确认'),
      //       )
      //     ],
      //   );
      case UpdateClassScheduleState.setSemesterStartDate: // 设置学期开始日期
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('成功获取课表数据，', style: Theme.of(context).textTheme.bodyMedium),
              Text('请选择学期开始日期：', style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10),
              Text(
                '⚠️注意：请选择预备周（第一周）的周一，而不是第一天开始上课的日期（正式开始上课是第二周）',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                  '参考：',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                GestureDetector(
                  onTap: () {
                    openLink(xtuSchoolCalendarUrl);
                  },
                  onLongPress: () {
                    Clipboard.setData(
                        ClipboardData(text: xtuSchoolCalendarUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("链接已复制到剪贴板")),
                    );
                  },
                  child: Text(
                    '校历',
                    style: TextStyle(
                      color: Colors.indigo.shade900,
                      decoration: TextDecoration.underline,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ]),
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
                            style: Theme.of(context).textTheme.bodyLarge,
                          );
                        }),
                    IconButton(
                      onPressed: () async {
                        await selectSemesterStartDate(context);
                      },
                      icon: Icon(Icons.edit_calendar_outlined),
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
      case UpdateClassScheduleState.loginExpired:
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              LoginExpiredQZ(onGoBack: (value) => onGoBack(value)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text('确认'),
            )
          ],
        );
      case UpdateClassScheduleState.getSemestersFailed: // 获取可选学期失败
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('获取可选学期失败:'),
              SizedBox(height: 4),
              Text(_getSemestesrFailedErrorMsg),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _getSemesters();
              },
              child: const Text('重试'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
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
              onPressed: () async {
                await _updateClassSchedule(context);
              },
              child: const Text('重试'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text('确认'),
            )
          ],
        );
    }
  }
}
