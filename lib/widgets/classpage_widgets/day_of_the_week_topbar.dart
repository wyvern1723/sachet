import 'package:flutter/material.dart';
import 'package:sachet/utils/time_manager.dart';

import '../../utils/transform.dart';

class DayOfTheWeekTopBar extends StatelessWidget {
  final int weekCount;
  final DateTime semesterStartDate;
  const DayOfTheWeekTopBar({
    super.key,
    required this.weekCount,
    required this.semesterStartDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 几月
        Expanded(
          flex: 4,
          child: Text(
            "${getTheMondayDateOfTheWeek(semesterStartDate, weekCount).month}月",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // 周几几号
        for (int weekday = 1; weekday <= DateTime.daysPerWeek; weekday++)
          Expanded(
            flex: 5,
            child: DateAndWeekday(
              weekCount: weekCount,
              weekday: weekday,
              semesterStartDate: semesterStartDate,
            ),
          ),
      ],
    );
  }
}

class DateAndWeekday extends StatelessWidget {
  const DateAndWeekday({
    super.key,
    required this.weekCount,
    required this.weekday,
    required this.semesterStartDate,
  });
  final int weekCount;
  final int weekday;
  final DateTime semesterStartDate;

  @override
  Widget build(BuildContext context) {
    DateTime thatDay = getDateFromWeekCountAndWeekday(
      semesterStartDate: semesterStartDate,
      weekCount: weekCount,
      weekday: weekday,
    );
    // ignore: no_leading_underscores_for_local_identifiers
    bool _isToday = isToday(thatDay);
    return Container(
      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
      // height: 40,
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black12, width: 0.5), // 边框
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 周几
          Text(
            weekdayToZhouJi[weekday] ?? '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              // // 判断是不是今天，如果是，以主题强调色强调
              color: _isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          //几月几日
          Text(
            "${thatDay.month}/${thatDay.day}",
            style: TextStyle(
              fontSize: 10,
              // 判断是不是今天，如果是，以主题强调色强调
              color: _isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
