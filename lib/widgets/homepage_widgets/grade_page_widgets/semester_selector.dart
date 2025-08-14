import 'package:flutter/material.dart';
import 'package:sachet/providers/grade_page_provider.dart';
import 'package:provider/provider.dart';

class SemesterSelector extends StatelessWidget {
  const SemesterSelector({
    super.key,
    required this.data,
    required this.menuHeight,
    required this.initialSelection,
  });
  final Map data;
  final double menuHeight;
  final String initialSelection;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      menuHeight: menuHeight,
      initialSelection: initialSelection,
      requestFocusOnTap: false,
      label: const Text('学期'),
      onSelected: (String? date) {
        if (date != null) {
          context.read<GradePageProvider>().changeSemester(date);
        }
      },
      dropdownMenuEntries: data.entries
          .map((e) => DropdownMenuEntry<String>(
                value: e.value,
                label: e.key,
              ))
          .toList(),
    );
  }
}
