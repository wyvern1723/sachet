import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/gpa_page_zf_provider.dart';

class CourseTypeSelectorZF extends StatelessWidget {
  /// 绩点排名查询页面（正方教务）选择课程属性的 DropDownMenu
  const CourseTypeSelectorZF({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    final Map courseTypes = {"全部": "", "必修": "bx", "选修": "xx"};
    String courseType = context
        .select<GPAPageZFProvider, String>((provider) => provider.courseType);
    return DropdownMenu<String>(
      width: width,
      menuHeight: 600,
      initialSelection: courseType,
      requestFocusOnTap: false,
      label: const Text('课程属性'),
      onSelected: (String? value) {
        if (value != null) {
          context.read<GPAPageZFProvider>().changeCourseType(value);
        }
      },
      dropdownMenuEntries: courseTypes.entries
          .map((e) => DropdownMenuEntry<String>(value: e.value, label: e.key))
          .toList(),
    );
  }
}
