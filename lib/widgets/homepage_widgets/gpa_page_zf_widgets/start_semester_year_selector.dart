import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/gpa_page_zf_provider.dart';

class StartSemesterSelectorZF extends StatelessWidget {
  /// 绩点排名查询页面（正方教务）选择起始学年学期的 DropDownMenu
  const StartSemesterSelectorZF({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    String selectedStartSemester = context.select<GPAPageZFProvider, String>(
        (provider) => provider.selectedStartSemester);
    Map startSemesters = context
        .select<GPAPageZFProvider, Map>((provider) => provider.startSemesters);
    return DropdownMenu<String>(
      width: width,
      menuHeight: 600,
      initialSelection: selectedStartSemester,
      requestFocusOnTap: false,
      label: const Text('起始学年学期'),
      onSelected: (String? value) {
        if (value != null) {
          context.read<GPAPageZFProvider>().changeStartSemester(value);
        }
      },
      dropdownMenuEntries: startSemesters.entries
          .map((e) => DropdownMenuEntry<String>(value: e.value, label: e.key))
          .toList(),
    );
  }
}
