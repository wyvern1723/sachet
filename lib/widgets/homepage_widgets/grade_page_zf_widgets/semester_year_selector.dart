import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/grade_page_zf_provider.dart';

class SemesterYearSelectorZF extends StatelessWidget {
  /// 成绩查询页面（正方教务）选择要查询的学年的 DropDownMenu
  const SemesterYearSelectorZF({super.key});

  @override
  Widget build(BuildContext context) {
    String selectedSemesterYear = context.select<GradePageZFProvider, String>(
        (provider) => provider.selectedSemesterYear);
    Map semestersYears = context.select<GradePageZFProvider, Map>(
        (provider) => provider.semestersYears);
    return DropdownMenu<String>(
      width: 160,
      menuHeight: 600,
      initialSelection: selectedSemesterYear,
      requestFocusOnTap: false,
      label: const Text('学年'),
      onSelected: (String? value) {
        if (value != null) {
          context.read<GradePageZFProvider>().changeSemesterYear(value);
        }
      },
      dropdownMenuEntries: semestersYears.entries
          .map((e) => DropdownMenuEntry<String>(value: e.value, label: e.key))
          .toList(),
    );
  }
}
