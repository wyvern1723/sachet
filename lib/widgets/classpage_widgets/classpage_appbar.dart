import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/enums/app_folder.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/pages/class_child_pages/course_settings_page.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/classpage_widgets/course_notification_enable_prompt_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/course_notification_reset_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/export_class_schedule_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/month_count_dropdown_menu.dart';
import 'package:sachet/widgets/classpage_widgets/switch_actived_app_file_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/update_class_schedule_zf_dialog.dart';
import 'package:sachet/widgets/classpage_widgets/week_count_dropdown_menu.dart';
import 'package:path/path.dart' as path;

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
    final String classScheduleFilePath =
        context.read<SettingsProvider>().classScheduleFilePath;
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => SwitchActivedAppFileDialog(
        dialogTitle: '选择课表',
        fileDirectory: AppFolder.classSchedule.name,
        settingsFilePath: classScheduleFilePath,
      ),
    );

    if (!context.mounted) return;

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

    final bool? result = await showDialog(
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
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('注意'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '课表导入后将使用离线数据，课程表数据不会自动更新。',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  '如发生以下情况，请手动重新获取：',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  '• 完成选课\n'
                  '• 完成体育选课\n'
                  '• 修改选课\n'
                  '• 教师在教务系统调课\n'
                  '• 进入新学期',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('我知道了'),
            )
          ],
        ),
      );
    }

    if (!context.mounted) {
      return;
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
  void navToLastWeek(BuildContext context) {
    final classPageModel = context.read<ClassPageProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    // classPageModel.decrementCurrentWeekCount();
    // 第一个 -1 表示上一周，第二个 -1 是周次到 pagelist 序号的转换（第一周 => 第0页）
    context.read<ClassPageProvider>().pageController.animateToPage(
        (classPageModel.currentWeekCount - 1 - 1),
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType] ?? Easing.standard);
  }

  /// 去下一周
  void navToNextWeek(BuildContext context) {
    final classPageModel = context.read<ClassPageProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    // classPageModel.incrementCurrentWeekCount();
    // +1 表示下一周，-1 是周次到 pagelist 序号的转换（第一周 => 第0页）
    context.read<ClassPageProvider>().pageController.animateToPage(
        (classPageModel.currentWeekCount + 1 - 1),
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType] ?? Easing.standard);
  }

  /// 回到本周
  void navToThisWeek(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    // context.read<ClassPageModel>().resetCurrentWeekCount();
    context.read<ClassPageProvider>().pageController.animateToPage(
        weekCountOfToday(DateTime.parse(SettingsProvider.semesterStartDate)) -
            1,
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType] ?? Easing.standard);
  }

  /// 去上个月
  void navToLastMonth(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();

    context.read<ClassPageProvider>().animateToLastMonth(
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType]);
  }

  /// 去下个月
  void navToNextMonth(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();

    context.read<ClassPageProvider>().animateToNextMonth(
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType]);
  }

  /// 回到本月
  void navToThisMonth(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();

    context.read<ClassPageProvider>().animateToTodayMonth(
        duration: Duration(milliseconds: settingsProvider.curveDuration),
        curve: curveTypes[settingsProvider.curveType]);
  }

  /// 从获取课表默认保存的文件名提取当前学期
  ///
  /// e.g.
  ///
  /// "class_schedule_2025-2026-2_20260404155500" => "2025-2026-2"
  ///
  /// "class_schedule_2025-2026-1_20250825111641" => "2025-2026-1"
  String extractSemester(String filename) {
    final regex = RegExp(r'class_schedule_(\d{4}-\d{4}-\d+)');
    final match = regex.firstMatch(filename);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }

    // throw FormatException('无法从文件名 "$filename" 中提取学期信息');
    return filename;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      titleSpacing: 16.0,
      title: Selector<ClassPageProvider, ClassScheduleViewMode>(
          selector: (_, provider) => provider.currentViewMode,
          builder: (_, currentViewMode, __) {
            switch (currentViewMode) {
              case ClassScheduleViewMode.week:
                return WeekCountDropdownMenu();
              case ClassScheduleViewMode.month:
                return MonthCountDropdownMenu();
              case ClassScheduleViewMode.semester:
                return Selector<SettingsProvider, String>(
                    selector: (_, provider) => provider.classScheduleFilePath,
                    builder: (_, classScheduleFilePath, __) {
                      final String currentSemester = extractSemester(
                        path.basenameWithoutExtension(classScheduleFilePath),
                      );
                      return Text(
                        currentSemester,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    });
            }
          }),
      actions: [
        // 切换周/月视图
        Selector<ClassPageProvider, ClassScheduleViewMode>(
            selector: (_, provider) => provider.currentViewMode,
            builder: (_, currentViewMode, __) {
              return ViewModeToggle(
                currentViewMode: currentViewMode,
                onModeChanged: (mode) => context
                    .read<ClassPageProvider>()
                    .updateClassScheduleViewMode(mode),
              );
            }),

        // 上一页（上一周/上个月）和下一页（下一周/下个月）的翻页箭头（方便大屏设备/桌面端）
        Selector<SettingsProvider, bool>(
            selector: (_, settingsProvider) =>
                settingsProvider.isShowPageTurnArrow,
            builder: (_, isShowPageTurnArrow, __) {
              // 是否显示翻页箭头
              if (isShowPageTurnArrow) {
                return Selector<ClassPageProvider, ClassScheduleViewMode>(
                    selector: (_, classPageProvider) =>
                        classPageProvider.currentViewMode,
                    builder: (_, currentViewMode, __) {
                      switch (currentViewMode) {
                        case ClassScheduleViewMode.week:
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.skip_previous_outlined),
                                tooltip: '上一周',
                                onPressed: () => navToLastWeek(context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next_outlined),
                                tooltip: '下一周',
                                onPressed: () => navToNextWeek(context),
                              ),
                            ],
                          );
                        case ClassScheduleViewMode.month:
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.skip_previous_outlined),
                                tooltip: '上个月',
                                onPressed: () => navToLastMonth(context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next_outlined),
                                tooltip: '下个月',
                                onPressed: () => navToNextMonth(context),
                              ),
                            ],
                          );
                        case ClassScheduleViewMode.semester:
                          return const SizedBox.shrink();
                      }
                    });
              } else {
                return SizedBox();
              }
            }),

        // 回到今天（回到本周/回到本月）
        Selector<ClassPageProvider, ClassScheduleViewMode>(
            selector: (_, provider) => provider.currentViewMode,
            builder: (_, currentViewMode, __) {
              switch (currentViewMode) {
                case ClassScheduleViewMode.week:
                  return IconButton(
                    icon: const Icon(Icons.today),
                    tooltip: '回到本周',
                    onPressed: () => navToThisWeek(context),
                  );
                case ClassScheduleViewMode.month:
                  return IconButton(
                    icon: const Icon(Icons.today),
                    tooltip: '回到本月',
                    onPressed: () => navToThisMonth(context),
                  );
                case ClassScheduleViewMode.semester:
                  return const SizedBox.shrink();
              }
            }),

        PopupMenuButton(
          tooltip: '更多操作',
          itemBuilder: (context) => [
            // 更新课表
            PopupMenuItem(
              onTap: () async {
                await showUpdateClassScheduleDialog(context);
              },
              child: Row(children: [
                Icon(Icons.refresh, color: colorScheme.onSurfaceVariant),
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
                    color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('切换课表'),
              ]),
            ),
            // 导出课表
            PopupMenuItem(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      ExportClassScheduleDialog(),
                );
              },
              child: Row(children: [
                Icon(Icons.share_outlined, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('导出课表')
              ]),
            ),
            // 课表设置
            PopupMenuItem(
              onTap: () async {
                final semesterStartDate = SettingsProvider.semesterStartDate;
                await Navigator.of(context).push(MaterialPageRoute(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return const CourseSettingsPage();
                  },
                ));
                final newSmesterStartDate = SettingsProvider.semesterStartDate;
                if (semesterStartDate != newSmesterStartDate) {
                  if (!context.mounted) {
                    return;
                  }
                  context.read<ClassPageProvider>().updateMonthList();
                  context
                      .read<ClassPageProvider>()
                      .updateCurrentMonth(DateTime.now().month);
                }
              },
              child: Row(children: [
                Icon(Icons.tune_outlined, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('课表设置')
              ]),
            ),
          ],
        ),
      ],
    );
  }
}

class ViewModeToggle extends StatelessWidget {
  final ClassScheduleViewMode currentViewMode;
  final ValueChanged<ClassScheduleViewMode> onModeChanged;

  /// 切换周/月视图
  const ViewModeToggle({
    super.key,
    required this.currentViewMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isWideScreen = screenWidth >= 600;

        if (isWideScreen) {
          // 宽屏：使用 SegmentedButton
          return SegmentedButton<ClassScheduleViewMode>(
            segments: const [
              ButtonSegment(
                value: ClassScheduleViewMode.week,
                label: Text('周'),
                icon: Icon(Icons.calendar_view_week),
                tooltip: '周视图',
              ),
              ButtonSegment(
                value: ClassScheduleViewMode.month,
                label: Text('月'),
                icon: Icon(Icons.calendar_view_month),
                tooltip: '月视图',
              ),
              ButtonSegment(
                value: ClassScheduleViewMode.semester,
                label: Text('学期'),
                icon: Icon(Icons.calendar_view_day),
                tooltip: '学期视图',
              ),
            ],
            selected: {currentViewMode},
            onSelectionChanged: (selected) {
              if (selected.isNotEmpty) {
                onModeChanged(selected.first);
              }
            },
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          );
        } else {
          // 窄屏：使用 PopupMenuButton
          return PopupMenuButton<ClassScheduleViewMode>(
            icon: Icon(
              currentViewMode == ClassScheduleViewMode.week
                  ? Icons.calendar_view_week
                  : currentViewMode == ClassScheduleViewMode.month
                      ? Icons.calendar_view_month
                      : Icons.view_compact_outlined,
            ),
            tooltip: '切换视图',
            itemBuilder: (context) => [
              // 切换到周视图
              PopupMenuItem(
                value: ClassScheduleViewMode.week,
                child: Row(children: [
                  Icon(
                    Icons.calendar_view_week,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  const Text('周视图'),
                ]),
              ),
              // 切换到月视图
              PopupMenuItem(
                value: ClassScheduleViewMode.month,
                child: Row(children: [
                  Icon(
                    Icons.calendar_view_month,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  const Text('月视图'),
                ]),
              ),
              // 切换到学期视图
              PopupMenuItem(
                value: ClassScheduleViewMode.semester,
                child: Row(children: [
                  Icon(
                    Icons.view_compact_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  const Text('学期视图'),
                ]),
              ),
            ],
            onSelected: onModeChanged,
          );
        }
      },
    );
  }
}
