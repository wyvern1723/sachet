import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/rounded_rectangle_container.dart';

class ChooseTeachingBuilding extends StatelessWidget {
  /// 选择教学楼
  const ChooseTeachingBuilding({
    super.key,
    required this.filterOptions,
    this.selectedOption,
  });
  final Map<String, String> filterOptions;
  final String? selectedOption;

  @override
  Widget build(BuildContext context) {
    String selectedTeachingBuilding =
        context.select<FreeClassroomPageZFProvider, String>(
            (freeClassroomPageZFProvider) =>
                freeClassroomPageZFProvider.selectedTeachingBuilding);
    return RoundedRectangleContainer(
      title: Text(
        '教学楼',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      direction: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 4.0),
        child: DropdownMenu<String>(
          textStyle: TextStyle(fontSize: 14),
          width: 220,
          // menuHeight: 400,
          initialSelection: selectedTeachingBuilding,
          requestFocusOnTap: false,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
              return switch ((
                Theme.of(context).brightness,
                states.contains(WidgetState.disabled)
              )) {
                (Brightness.dark, true) => const Color(0x0DFFFFFF), //  5% white
                (Brightness.dark, false) =>
                  const Color(0x1AFFFFFF), // 10% white
                (Brightness.light, true) =>
                  const Color(0x05000000), //  2% black
                (Brightness.light, false) =>
                  const Color(0x0A000000), //  4% black
              };
            }),
            contentPadding:
                EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          ),
          onSelected: (String? value) {
            if (value != null) {
              context
                  .read<FreeClassroomPageZFProvider>()
                  .setSelectedTeachingBuilding(value);
            }
          },
          dropdownMenuEntries:
              filterOptions.entries.map<DropdownMenuEntry<String>>((e) {
            return DropdownMenuEntry<String>(
              value: e.value,
              label: e.key,
            );
          }).toList(),
        ),
      ),
    );
  }
}
