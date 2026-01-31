import 'package:flutter/material.dart';

/// 用于 [GradePageZF] 正方教务系统的成绩查询页面的 Provider
class GradePageZFProvider extends ChangeNotifier {
  bool _isSelectingSemester = true; // true 为处于选择学期的状态，false 为查看成绩的状态
  bool get isSelectingSemester => _isSelectingSemester;

  Map _semestersYears = {};
  Map get semestersYears => _semestersYears;

  String _selectedSemesterYear = '';
  String get selectedSemesterYear => _selectedSemesterYear;

  String _selectedSemesterIndex = '';
  String get selectedSemesterIndex => _selectedSemesterIndex;

  List<String> _items = ['学期', '课程名称', '任课教师', '学分', '成绩', '绩点', '课程性质'];
  List<String> get items => _items;

  List<String> _selectedItems = ['课程名称', '学分', '成绩'];
  List<String> get selectedItems => _selectedItems;

  List<String> _alertTexts = [];
  List<String> get alertTexts => _alertTexts;

  void changeSemesterYear(String value) {
    _selectedSemesterYear = value;
    notifyListeners();
  }

  void changeSemesterIndex(String value) {
    _selectedSemesterIndex = value;
    notifyListeners();
  }

  void setSemestersYears(Map value) {
    _semestersYears = value;
    notifyListeners();
  }

  void setIsSelectingSemester(bool value) {
    _isSelectingSemester = value;
    notifyListeners();
  }

  void updateSelectedItems(List<String> value) {
    _selectedItems = value;
    notifyListeners();
  }

  void updateItems(List<String> value) {
    _items = value;
    notifyListeners();
  }

  void setAlertText(List<String> value) {
    _alertTexts = value;
    notifyListeners();
  }
}
