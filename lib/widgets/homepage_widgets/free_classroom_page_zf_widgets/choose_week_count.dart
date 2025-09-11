import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/rounded_rectangle_container.dart';

class ChooseWeekCount extends StatelessWidget {
  /// 选择周次
  const ChooseWeekCount({super.key, this.isSingleChoice = false});
  final bool isSingleChoice;

  @override
  Widget build(BuildContext context) {
    List<bool> weeksSelection =
        context.select<FreeClassroomPageZFProvider, List<bool>>(
            (freeClassroomPageZFProvider) =>
                freeClassroomPageZFProvider.weekCountsSelection);
    List<Widget> weekCountToggleButtons =
        weekCountOptions.map((e) => Text(e.toString())).toList();
    return GestureDetector(
      onLongPress: isSingleChoice
          ? null
          : () {
              if (weeksSelection.every((e) => e == false)) {
                context
                    .read<FreeClassroomPageZFProvider>()
                    .setSelectedWeekCountsAddAll();
              } else {
                context
                    .read<FreeClassroomPageZFProvider>()
                    .setSelectedWeekCountsRemoveAll();
              }
            },
      child: RoundedRectangleContainer(
        title: Text(
          '周次',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ToggleButtons(
              constraints: const BoxConstraints(
                minHeight: 28.0,
                minWidth: 28.0,
              ),
              isSelected: weeksSelection.sublist(0, 10),
              onPressed: (int index) {
                context
                    .read<FreeClassroomPageZFProvider>()
                    .setSelectedWeekCount(
                      weekCountOptions[index],
                      isSingleChoice,
                    );
              },
              children: weekCountToggleButtons.sublist(0, 10),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ToggleButtons(
              constraints: const BoxConstraints(
                minHeight: 28.0,
                minWidth: 28.0,
              ),
              isSelected: weeksSelection.sublist(10),
              onPressed: (int index) {
                context
                    .read<FreeClassroomPageZFProvider>()
                    .setSelectedWeekCount(
                      weekCountOptions[index + 10],
                      isSingleChoice,
                    );
              },
              children: weekCountToggleButtons.sublist(10),
            ),
          ),
        ],
      ),
    );
  }
}
