import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/rounded_rectangle_container.dart';

class ChooseSession extends StatelessWidget {
  // 选择节次
  const ChooseSession({super.key});

  @override
  Widget build(BuildContext context) {
    List<bool> sessionsSelection =
        context.select<FreeClassroomPageZFProvider, List<bool>>(
            (freeClassroomPageZFProvider) =>
                freeClassroomPageZFProvider.sessionsSelection);
    final List<Widget> sessionToggleButtons =
        sessionOptions.map((e) => Text(e.toString())).toList();
    return GestureDetector(
      onLongPress: () {
        // 如果什么都没选择，全选
        if (sessionsSelection.every((e) => e == false)) {
          context
              .read<FreeClassroomPageZFProvider>()
              .setSelectedSessionsAddAll();
        } else {
          // 如果有选择项，清除全部
          context
              .read<FreeClassroomPageZFProvider>()
              .setSelectedSessionsRemoveAll();
        }
      },
      child: RoundedRectangleContainer(
        title: Text(
          '节次',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            child: ToggleButtons(
              constraints: const BoxConstraints(
                minHeight: 28.0,
                minWidth: 28.0,
              ),
              isSelected: sessionsSelection,
              onPressed: (int index) {
                context
                    .read<FreeClassroomPageZFProvider>()
                    .setSelectedSession(sessionOptions[index]);
              },
              children: sessionToggleButtons,
            ),
          ),
        ),
      ),
    );
  }
}
