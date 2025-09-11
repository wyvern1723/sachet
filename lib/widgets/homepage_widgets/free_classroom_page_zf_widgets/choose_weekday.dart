import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/rounded_rectangle_container.dart';

class ChooseWeekday extends StatelessWidget {
  /// 选择星期几
  const ChooseWeekday({super.key, this.isSingleChoice = false});
  final bool isSingleChoice;

  @override
  Widget build(BuildContext context) {
    List<bool> weekdaySelection =
        context.select<FreeClassroomPageZFProvider, List<bool>>(
            (freeClassroomPageZFProvider) =>
                freeClassroomPageZFProvider.weekdaysSelection);
    List<Widget> weekdayToggleButtons =
        weekdayOptions.map((e) => Text(e.toString())).toList();
    return GestureDetector(
      onLongPress: isSingleChoice
          ? null
          : () {
              // 如果什么都没选择，全选
              if (weekdaySelection.every((e) => e == false)) {
                context
                    .read<FreeClassroomPageZFProvider>()
                    .setSelectedWeekdaysAddAll();
              } else {
                // 如果有选择项，清除全部
                context
                    .read<FreeClassroomPageZFProvider>()
                    .setSelectedWeekdaysRemoveAll();
              }
            },
      child: RoundedRectangleContainer(
        title: Text(
          '星期',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        direction: Axis.horizontal,
        child: ToggleButtons(
          constraints: const BoxConstraints(
            minHeight: 30.0,
            minWidth: 30.0,
          ),
          isSelected: weekdaySelection,
          onPressed: (int index) {
            context.read<FreeClassroomPageZFProvider>().setSelectedWeekday(
                  weekdayOptions[index],
                  isSingleChoice,
                );
          },
          children: weekdayToggleButtons,
        ),
      ),
    );
  }
}
