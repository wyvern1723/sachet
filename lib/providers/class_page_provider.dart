import 'dart:math';

import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/time_manager.dart';

class MonthData {
  int index;
  int month;
  DateTime monthDate;
  String label;
  MonthData(this.index, this.month, this.monthDate, this.label);
}

enum ClassScheduleViewMode { week, month }

class ClassPageProvider extends ChangeNotifier {
  // 转到 Class_Page 页面中的数字时需要转化, pageList 的 list 是 [0,1,2...19]
  // 第一页(pagelist[0]) => 第一周
  // 所以需要 - 1
  // 比如  _pageController.animateToPage(int index),index = currentWeekCount - 1;

  // final int _todayWeekCount = weekCountOfToday(semesterStartDate);
  // int get todayWeekCount => _todayWeekCount;

  // 当前页面周次（显示的周次，会随着页面的变化变化）
  int _currentWeekCount = min(
      weekCountOfToday(DateTime.parse(SettingsProvider.semesterStartDate)),
      20); // 如果当前周次超过最大周次，使用最大周次(防止超出 List length,虽然实际上完全不会报错)
  int get currentWeekCount => _currentWeekCount;

  int _currentMonth = DateTime.now().month;
  int get currentMonth => _currentMonth;

  PageController _pageController = PageController(
      initialPage: min(
              weekCountOfToday(
                  DateTime.parse(SettingsProvider.semesterStartDate)),
              20) -
          1);
  PageController get pageController => _pageController;

  ClassScheduleViewMode _currentViewMode = ClassScheduleViewMode.week;
  ClassScheduleViewMode get currentViewMode => _currentViewMode;

  List<MonthData> _monthList = getMonthList(
      DateTime.tryParse(SettingsProvider.semesterStartDate) ??
          constSemesterStartDate,
      getDateFromWeekCountAndWeekday(
        semesterStartDate:
            DateTime.tryParse(SettingsProvider.semesterStartDate) ??
                constSemesterStartDate,
        weekCount: 20,
        weekday: 7,
      ));
  List<MonthData> get monthList => _monthList;

  static List<MonthData> getMonthList(DateTime startDate, DateTime endDate) {
    final List<MonthData> monthList = [];
    final start = DateTime(startDate.year, startDate.month);
    final end = DateTime(endDate.year, endDate.month);
    DateTime iterateMonth = start;
    int index = 0;
    while (!iterateMonth.isAfter(end)) {
      monthList.add(
        MonthData(
          index,
          iterateMonth.month,
          iterateMonth,
          '${iterateMonth.year}年${iterateMonth.month}月',
        ),
      );
      index++;
      iterateMonth = iterateMonth.month == 12
          ? DateTime(iterateMonth.year + 1, 1)
          : DateTime(iterateMonth.year, iterateMonth.month + 1);
    }
    return monthList;
  }

  // // 初始化周次信息
  // void initValue() {
  //   var value = weekCountOfToday(DateTime(2024, 8, 26));
  //   _todayWeekCount = value;
  //   if (value > 20) {
  //     _currentWeekCount = 20;
  //   } else {
  //     _currentWeekCount = _todayWeekCount;
  //   }
  //   notifyListeners();
  // }

  // 更新当前周次
  void resetCurrentWeekCount() {
    _currentWeekCount =
        weekCountOfToday(DateTime.parse(SettingsProvider.semesterStartDate));
    notifyListeners();
  }

  // 更新当前周次
  void updateCurrentWeekCount(int i) {
    _currentWeekCount = i;
    notifyListeners();
  }

  void incrementCurrentWeekCount() {
    if (_currentWeekCount < 20) {
      _currentWeekCount++;
      notifyListeners();
    }
  }

  void decrementCurrentWeekCount() {
    if (_currentWeekCount > 1) {
      _currentWeekCount--;
      notifyListeners();
    }
  }

  void updatePageController(int index) {
    _pageController = PageController(initialPage: index - 1);
    notifyListeners();
  }

  // 更新当前月份
  void updateCurrentMonth(int month) {
    _currentMonth = month;
    notifyListeners();
  }

  void updateCurrentMonthByIndex(int index) {
    final newMonth = monthList.firstWhereOrNull((e) => e.index == index)?.month;
    if (newMonth == null) {
      return;
    }
    _currentMonth = newMonth;
    updateCurrentMonth(_currentMonth);
  }

  void animateToMonth({required int month, Duration? duration, Curve? curve}) {
    final index = monthList.firstWhereOrNull((e) => e.month == month)?.index;
    if (index == null) {
      return;
    }
    pageController.animateToPage(
      index,
      duration: duration ?? Duration(milliseconds: 1500),
      curve: curve ?? Easing.standard,
    );
    notifyListeners();
  }

  void jumpToMonth({required int month, Duration? duration, Curve? curve}) {
    final newIndex = monthList.firstWhereOrNull((e) => e.month == month)?.index;
    if (newIndex == null) {
      return;
    }
    pageController.jumpToPage(newIndex);
    notifyListeners();
  }

  void updateMonthList() {
    _monthList = getMonthList(
        DateTime.tryParse(SettingsProvider.semesterStartDate) ??
            constSemesterStartDate,
        getDateFromWeekCountAndWeekday(
          semesterStartDate: DateTime.parse(SettingsProvider.semesterStartDate),
          weekCount: 20,
          weekday: 7,
        ));
    notifyListeners();
  }

  void updateClassScheduleViewMode(ClassScheduleViewMode viewMode) {
    _currentViewMode = viewMode;
    notifyListeners();
  }
}
