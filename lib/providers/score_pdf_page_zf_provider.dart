import 'package:flutter/material.dart';

/// 用于 [ScorePdfPageZF] 正方教务系统的成绩单pdf打印页面的 Provider
class ScorePdfPageZFProvider extends ChangeNotifier {
  /// 可选的成绩单格式
  Map _scorePdfTypes = {};

  /// 可选的成绩单格式
  Map get scorePdfTypes => _scorePdfTypes;

  /// 当前选择的成绩单格式
  String _selectedScorePdfType = '';

  /// 当前选择的成绩单格式
  String get selectedScorePdfType => _selectedScorePdfType;

  bool _isShowDropDownMenuError = false;
  bool get isShowDropDownMenuError => _isShowDropDownMenuError;

  void setScorePdfTypes(Map value) {
    _scorePdfTypes = value;
    notifyListeners();
  }

  void changeScorePdfType(String value) {
    _selectedScorePdfType = value;
    notifyListeners();
  }

  void changeIsShowDropDownMenuError(bool value) {
    _isShowDropDownMenuError = value;
    notifyListeners();
  }
}
