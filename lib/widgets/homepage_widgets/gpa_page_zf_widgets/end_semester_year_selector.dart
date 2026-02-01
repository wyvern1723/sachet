import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/gpa_page_zf_provider.dart';

class EndSemesterSelectorZF extends StatelessWidget {
  /// 绩点排名查询页面（正方教务）选择终止学年学期的 DropDownMenu
  const EndSemesterSelectorZF({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    String selectedEndSemester = context.select<GPAPageZFProvider, String>(
        (provider) => provider.selectedEndSemester);
    Map endSemesters = context
        .select<GPAPageZFProvider, Map>((provider) => provider.endSemesters);
    return DropdownMenu<String>(
      width: width,
      menuHeight: 600,
      initialSelection: selectedEndSemester,
      requestFocusOnTap: false,
      label: const Text('终止学年学期'),
      onSelected: (String? value) {
        if (value != null) {
          context.read<GPAPageZFProvider>().changeEndSemester(value);
        }
      },
      dropdownMenuEntries: endSemesters.entries
          .map((e) => DropdownMenuEntry<String>(value: e.value, label: e.key))
          .toList(),
    );
  }
}
