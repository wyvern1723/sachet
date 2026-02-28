import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/grade_page_zf_provider.dart';

class SemesterIndexSelectorZF extends StatelessWidget {
  /// 成绩查询页面（正方教务）选择要查询的学期的 DropDownMenu
  const SemesterIndexSelectorZF({super.key});

  @override
  Widget build(BuildContext context) {
    final Map semesterIndexes = {"全部": "", "1": "3", "2": "12"};
    String selectedSemesterIndex = context.select<GradePageZFProvider, String>(
        (provider) => provider.selectedSemesterIndex);
    return DropdownMenu<String>(
      width: 100,
      menuHeight: 400,
      initialSelection: selectedSemesterIndex,
      requestFocusOnTap: false,
      label: const Text('学期'),
      onSelected: (String? value) {
        if (value != null) {
          context.read<GradePageZFProvider>().changeSemesterIndex(value);
        }
      },
      dropdownMenuEntries: semesterIndexes.entries
          .map((e) => DropdownMenuEntry<String>(value: e.value, label: e.key))
          .toList(),
    );
  }
}
