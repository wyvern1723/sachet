import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:provider/provider.dart';

Future selectSemesterStartDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    locale: const Locale('zh', 'CN'),
    initialDate: DateTime.tryParse(SettingsProvider.semesterStartDate) ??
        constSemesterStartDate,
    firstDate: DateTime(1958, 6),
    lastDate: DateTime(2077, 12),
    selectableDayPredicate: (DateTime val) => val.weekday == 1 ? true : false,
    helpText: '选择学期开始日期',
  );

  if (picked != null) {
    context
        .read<SettingsProvider>()
        .setSemesterStartDate(picked.toIso8601String());
  }
}
