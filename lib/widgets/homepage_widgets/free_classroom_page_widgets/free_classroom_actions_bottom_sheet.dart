import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/utils_functions.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/set_free_classroom_sections_dialog.dart';

/// 空闲教室操作 BottomSheet 需要在关闭后继续执行的操作
enum FreeClassroomAction {
  /// 选择学期开始日期
  selectSemesterStartDate,

  /// 设置查询节次分段
  setSections,
}

class FreeClassroomActionsBottomSheet extends StatefulWidget {
  const FreeClassroomActionsBottomSheet({super.key});

  /// 打开空闲教室的操作 BottomSheet
  static Future<void> show(BuildContext context) async {
    final FreeClassroomAction? action =
        await showModalBottomSheet<FreeClassroomAction>(
      context: context,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) => const FreeClassroomActionsBottomSheet(),
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case FreeClassroomAction.selectSemesterStartDate:
        final String semesterStartDate = SettingsProvider.semesterStartDate;
        await selectSemesterStartDate(context);
        if (!context.mounted) return;

        // 周次是相对学期开始日期计算的，开始日期变化后需要重新计算周次
        if (SettingsProvider.semesterStartDate != semesterStartDate) {
          context
              .read<FreeClassroomPageZFProvider>()
              .resetSelectedWeekCountsAndNotify();
        }
        return;
      case FreeClassroomAction.setSections:
        await showDialog(
          context: context,
          builder: (context) => SetFreeClassroomSectionsDialog(),
        );
        return;
    }
  }

  @override
  State<FreeClassroomActionsBottomSheet> createState() =>
      _FreeClassroomActionsBottomSheetState();
}

class _FreeClassroomActionsBottomSheetState
    extends State<FreeClassroomActionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final safeAreaInsets = MediaQuery.of(context).padding;

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
          child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, 0, 0, safeAreaInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                    child: Text(
                      '设置',
                      style:
                          TextStyle(color: colorScheme.primary, fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: const Align(
                        widthFactor: 1,
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.edit_calendar_outlined)),
                    title: const Text('当前进行学期开始日期'),
                    subtitle: Selector<SettingsProvider, DateTime>(
                        selector: (_, settingsProvider) =>
                            SettingsProvider.semesterStartDateDateTime,
                        builder: (_, semesterStartDateDateTime, __) {
                          return Text(
                            DateFormat('yyyy-MM-dd')
                                .format(semesterStartDateDateTime),
                          );
                        }),
                    onTap: () async {
                      Navigator.pop(
                          context, FreeClassroomAction.selectSemesterStartDate);
                    },
                  ),
                  Selector<SettingsProvider, List>(
                      selector: (_, settingsProvider) =>
                          settingsProvider.freeClassroomSections,
                      builder: (_, sections, __) {
                        return ListTile(
                          leading: const Align(
                            widthFactor: 1,
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.horizontal_split),
                          ),
                          title: const Text('查询节次分段'),
                          subtitle: Text(sections.join(',  ')),
                          onTap: () {
                            Navigator.pop(
                                context, FreeClassroomAction.setSections);
                          },
                        );
                      }),
                ],
              )),
        ),
      ],
    );
  }
}
