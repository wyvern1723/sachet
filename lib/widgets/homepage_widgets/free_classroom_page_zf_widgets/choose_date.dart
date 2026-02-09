import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/rounded_rectangle_container.dart';

class ChooseDate extends StatefulWidget {
  /// 选择日期
  const ChooseDate({super.key});

  @override
  State<ChooseDate> createState() => _ChooseDateState();
}

class _ChooseDateState extends State<ChooseDate> {
  Future _selectDate(BuildContext context, DateTime selectedDate) async {
    final firstDate = getDateFromWeekCountAndWeekday(
      semesterStartDate: DateTime.parse(SettingsProvider.semesterStartDate),
      weekCount: 1,
      weekday: 1,
    );
    final lastDate = getDateFromWeekCountAndWeekday(
      semesterStartDate: DateTime.parse(SettingsProvider.semesterStartDate),
      weekCount: 20,
      weekday: 7,
    );
    final date = await showDatePicker(
      context: context,
      locale: const Locale('zh', 'CN'),
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: '选择日期',
    );
    if (date != null) {
      final result = getWeekCountAndWeekdayOfDate(
        semesterStartDate:
            DateTime.tryParse(SettingsProvider.semesterStartDate) ??
                constSemesterStartDate,
        date: date,
      );
      context
          .read<FreeClassroomPageZFProvider>()
          .setSelectedWeekCount(result.weekCount, true);
      context
          .read<FreeClassroomPageZFProvider>()
          .setSelectedWeekday(result.weekday, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate =
        context.select<FreeClassroomPageZFProvider, DateTime>(
            (freeClassroomPageZFProvider) =>
                freeClassroomPageZFProvider.selectedDate);
    return RoundedRectangleContainer(
      title: Text(
        '日期',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      direction: Axis.horizontal,
      child: SizedBox(
        width: 180,
        height: 60,
        child: GestureDetector(
          onTap: () async {
            await _selectDate(context, selectedDate);
          },
          child: Align(
            alignment: Alignment.center,
            child: InputDecorator(
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                isDense: false,
                border: UnderlineInputBorder(),
                // labelText: '日期',
                // border: OutlineInputBorder(),
                // contentPadding: EdgeInsets.all(0),
                suffixIcon: IconButton(
                  onPressed: () async {
                    await _selectDate(context, selectedDate);
                  },
                  icon: Icon(
                    Icons.edit_calendar_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              child: Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
