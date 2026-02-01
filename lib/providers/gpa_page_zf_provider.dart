import 'package:flutter/material.dart';

/// 用于 [GPAPageZF] 正方教务系统的绩点排名查询页面的 Provider
class GPAPageZFProvider extends ChangeNotifier {
  bool _isSelectingSemester = true; // true 为处于选择学期的状态，false 为查看成绩的状态
  bool get isSelectingSemester => _isSelectingSemester;

  Map _startSemesters = {};
  Map get startSemesters => _startSemesters;

  Map _endSemesters = {};
  Map get endSemesters => _endSemesters;

  String _selectedStartSemester = '';
  String get selectedStartSemester => _selectedStartSemester;

  String _selectedEndSemester = '';
  String get selectedEndSemester => _selectedEndSemester;

  String _courseType = '';
  String get courseType => _courseType;

  void changeStartSemester(String value) {
    _selectedStartSemester = value;
    notifyListeners();
  }

  void changeEndSemester(String value) {
    _selectedEndSemester = value;
    notifyListeners();
  }

  void changeCourseType(String value) {
    _courseType = value;
    notifyListeners();
  }

  void setStartSemestersYears(Map value) {
    _startSemesters = value;
    notifyListeners();
  }

  void setEndSemestersYears(Map value) {
    _endSemesters = value;
    notifyListeners();
  }

  void setIsSelectingSemester(bool value) {
    _isSelectingSemester = value;
    notifyListeners();
  }
}
