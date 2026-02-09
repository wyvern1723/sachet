import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/app_folder.dart';
import 'package:sachet/services/time_manager.dart';
import 'package:sachet/pages/class_child_pages/course_settings_page.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/classpage_widgets/course_notification_enable_prompt_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/course_notification_reset_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/export_class_schedule_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/switch_actived_app_file_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/update_class_schedule_zf_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/week_count_dropdown_menu.dart';

class ClassPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  ClassPageAppBar({super.key})
      : preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  State<ClassPageAppBar> createState() => _ClassPageAppBarState();
}

class _ClassPageAppBarState extends State<ClassPageAppBar> {
  Future switchClassSchedules(BuildContext context) async {
    String classScheduleFilePath =
        context.read<SettingsProvider>().classScheduleFilePath;
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => SwitchActivedAppFileDialog(
        dialogTitle: '选择课表',
        fileDirectory: AppFolder.classSchedule.name,
        settingsFilePath: classScheduleFilePath,
      ),
    );
    if (result is String) {
      context.read<SettingsProvider>().setClassScheduleFilePath(result);
    } else if (result == true) {
      // setState 只是为了「切换课表时编辑了当前课表文件的内容，且没有切换到其他课表」。
      // 这种情况下，使用的文件路径没有更新，不会触发 Provider 更新，所以需要刷新一下，重新读取修改后的文件。
      // TODO: 目前只是判断了是否编辑，没有判断是否编辑的文件和使用的课表文件是同一个文件。
      setState(() {});
    }
  }

  Future showUpdateClassScheduleDialog(BuildContext context) async {
    final String oldClassScheduleFilePath =
        context.read<SettingsProvider>().classScheduleFilePath;

    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) => const UpdateClassScheduleZFDialog(),
    );
    if (!context.mounted) return;

    if (result == true) {
      context.read<ClassPageProvider>().pageController.jumpToPage(
            weekCountOfToday(
                    DateTime.parse(SettingsProvider.semesterStartDate)) -
                1,
          );
    }

    final String newClassScheduleFilePath =
        context.read<SettingsProvider>().classScheduleFilePath;

    // 判断是否成功更新课表
    if (oldClassScheduleFilePath == newClassScheduleFilePath) {
      // 课表未更新，无需处理课程通知
      return;
    }

    // 以下为课表更新成功后的处理逻辑
    final isEnableCourseNotification =
        context.read<SettingsProvider>().isEnableCourseNotification;
    if (isEnableCourseNotification) {
      // ===== 用户之前启用了课程通知 =====
      // 取消之前安排的课程通知
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();

      if (!context.mounted) return;

      // 将「启用课程通知」状态设为关闭
      context.read<SettingsProvider>().setIsEnableCourseNotification(false);

      // 显示「课程通知已重置（关闭），需要重新设置课程通知」Dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) =>
            const CourseNotificationResetDialog(),
      );
    } else {
      //  ===== 用户之前未启用课程通知 =====
      // 显示「课程通知已关闭，是否要开启课程通知」Dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) =>
            const CourseNotificationEnablePromptDialog(),
      );
    }
  }

  /// 去上一周
  void navToLastWeek() {
    var classPageModel = context.read<ClassPageProvider>();
    var settingsProvider = context.read<SettingsProvider>();

    // classPageModel.decrementCurrentWeekCount();
    // 第一个 -1 表示上一周，第二个 -1 是周次到 pagelist 序号的转换（第一周 => 第0页）
    context.read<ClassPageProvider>().pageController.animateToPage(
        (classPageModel.currentWeekCount - 1 - 1),
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType] ?? Easing.standard);
  }

  /// 去下一周
  void navToNextWeek() {
    var classPageModel = context.read<ClassPageProvider>();
    var settingsProvider = context.read<SettingsProvider>();

    // classPageModel.incrementCurrentWeekCount();
    // +1 表示下一周，-1 是周次到 pagelist 序号的转换（第一周 => 第0页）
    context.read<ClassPageProvider>().pageController.animateToPage(
        (classPageModel.currentWeekCount + 1 - 1),
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType] ?? Easing.standard);
  }

  /// 回到本周
  void navToThisWeek() {
    var settingsProvider = context.read<SettingsProvider>();
    // context.read<ClassPageModel>().resetCurrentWeekCount();
    context.read<ClassPageProvider>().pageController.animateToPage(
        weekCountOfToday(DateTime.parse(SettingsProvider.semesterStartDate)) -
            1,
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType] ?? Easing.standard);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // title: Text(
      //   "第$_currentWeekCount周",
      // ),
      titleSpacing: 16.0,
      title: WeekCountDropdownMenu(),
      actions: [
        // 是否显示翻页箭头
        // 上一周
        Selector<SettingsProvider, bool>(
            selector: (_, settingsProvider) =>
                settingsProvider.isShowPageTurnArrow,
            builder: (_, isShowPageTurnArrow, __) {
              if (isShowPageTurnArrow) {
                return IconButton(
                    icon: const Icon(Icons.skip_previous_outlined),
                    tooltip: '上一周',
                    onPressed: () {
                      navToLastWeek();
                    });
              } else {
                return SizedBox();
              }
            }),

        // 下一周
        Selector<SettingsProvider, bool>(
            selector: (_, settingsProvider) =>
                settingsProvider.isShowPageTurnArrow,
            builder: (_, isShowPageTurnArrow, __) {
              if (isShowPageTurnArrow) {
                return IconButton(
                    icon: const Icon(Icons.skip_next_outlined),
                    tooltip: '下一周',
                    onPressed: () {
                      navToNextWeek();
                    });
              } else {
                return SizedBox();
              }
            }),
        // 回到今天
        IconButton(
            icon: const Icon(Icons.today),
            tooltip: '回到本周',
            onPressed: () {
              navToThisWeek();
            }),

        PopupMenuButton(
          itemBuilder: (context) => [
            // 更新课表
            PopupMenuItem(
              onTap: () async {
                await showUpdateClassScheduleDialog(context);
              },
              child: Row(children: [
                Icon(Icons.refresh,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('更新课表')
              ]),
            ),
            // 切换课表
            PopupMenuItem(
              onTap: () async {
                await switchClassSchedules(context);
              },
              child: Row(children: [
                Icon(Icons.swap_horiz_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('切换课表'),
              ]),
            ),
            // 课表设置
            PopupMenuItem(
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return const CourseSettingsPage();
                  },
                ));
              },
              child: Row(children: [
                Icon(Icons.tune_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('课表设置')
              ]),
            ),
            PopupMenuItem(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      ExportClassScheduleDialog(),
                );
              },
              child: Row(children: [
                Icon(Icons.share_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('导出课表')
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
