import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/services/get_jwxt_data/process_data/get_class_schedule.dart';
import 'package:sachet/services/get_jwxt_data/process_data/get_class_shedule_semesters.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/utils_widgets/login_expired.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum UpdateState {
  inquire, // 询问是否确认更新 (inquire vs none?)
  gettingSemester, // 获取学期（当前学期和其他可选学期）  成功 --> selectSemester; 失败 --> loginExpired/failed
  selectSemester, // 用户选择学期（默认是从网页获取的当前学期)   成功 --> updating; 失败 --> failed
  updating, // 开始更新
  setSemesterStartDate, // 设置学期开始日期
  // success, // 更新成功
  loginExpired, // 登录过期
  failed // 因为其它问题导致获取学期和更新课表失败
}

class UpdateClassScheduleDialog extends StatefulWidget {
  const UpdateClassScheduleDialog({super.key});

  @override
  State<UpdateClassScheduleDialog> createState() =>
      _UpdateClassScheduleDialogState();
}

class _UpdateClassScheduleDialogState extends State<UpdateClassScheduleDialog> {
  UpdateState currentState = UpdateState.inquire;
  Map semesters = {};
  String selectedSemester = '';

  /// 获取可选择学期和当前学期数据
  Future getSemesters() async {
    setState(() {
      currentState = UpdateState.gettingSemester;
    });
    await getClassScheduleSemestersData().then(
      (result) {
        if (!mounted) {
          return;
        }
        selectedSemester = result[0];
        semesters = result[1];
        setState(() {
          currentState = UpdateState.selectSemester;
        });
      },
      onError: (e) {
        if (!mounted) {
          return;
        }
        if (e == '登录失效，请重新登录') {
          setState(() {
            currentState = UpdateState.loginExpired;
          });
        } else {
          setState(() {
            currentState = UpdateState.failed;
          });
        }
      },
    );
  }

  Future updateClassSchedule() async {
    setState(() {
      currentState = UpdateState.updating;
    });
    await getClassScheduleData(selectedSemester).then(
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
          currentState = UpdateState.setSemesterStartDate;
        });
      },
      onError: (e) {
        if (!mounted) {
          return;
        }
        if (e == '登录失效，请重新登录') {
          setState(() {
            currentState = UpdateState.loginExpired;
          });
        } else {
          setState(() {
            currentState = UpdateState.failed;
          });
        }
      },
    );
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      getSemesters();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (currentState) {
      case UpdateState.inquire:
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Text('确认要更新课程表吗?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await getSemesters();
              },
              child: const Text('确认'),
            )
          ],
        );
      case UpdateState.gettingSemester:
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
      case UpdateState.selectSemester: // 选择学期
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
                await updateClassSchedule();
              },
              child: const Text('确认'),
            )
          ],
        );
      case UpdateState.updating: // 获取课表中
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
      case UpdateState.setSemesterStartDate: // 设置学期开始日期
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
      case UpdateState.loginExpired:
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              LoginExpired(onGoBack: (value) => onGoBack(value)),
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
      case UpdateState.failed:
        return AlertDialog(
          title: const Text('更新课程表'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text('更新失败'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await updateClassSchedule();
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
