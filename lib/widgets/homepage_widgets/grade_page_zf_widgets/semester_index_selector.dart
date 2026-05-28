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

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DropdownMenu<String>(
      // width: 100,
      // expandedInsets: EdgeInsets.zero,
      menuHeight: 400,
      initialSelection: selectedSemesterIndex,
      requestFocusOnTap: false,
      textStyle: textTheme.labelMedium,
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      menuStyle: MenuStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
      label: const Text('学期'),
      onSelected: (String? value) {
        if (value != null) {
          context.read<GradePageZFProvider>().changeSemesterIndex(value);
        }
      },
      dropdownMenuEntries: semesterIndexes.entries
          .map((e) => DropdownMenuEntry<String>(
                value: e.value,
                label: e.key,
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
                ),
              ))
          .toList(),
    );
  }
}
