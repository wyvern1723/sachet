import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/services/time_manager.dart';

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

  PageController _pageController = PageController(
      initialPage: min(
              weekCountOfToday(
                  DateTime.parse(SettingsProvider.semesterStartDate)),
              20) -
          1);
  PageController get pageController => _pageController;

  void updatePageController(int index) {
    _pageController = PageController(initialPage: index - 1);
    notifyListeners();
  }
}
