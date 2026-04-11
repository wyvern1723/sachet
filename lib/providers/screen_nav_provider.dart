import 'package:flutter/material.dart';
import 'package:sachet/utils/app_global.dart';

class ScreenNavProvider extends ChangeNotifier {
  static String _currentPage = AppGlobal.startupPage;
  static String get currentPage => _currentPage;

  static bool _isNavBottomVisible = true;
  bool get isNavBottomVisible => _isNavBottomVisible;

  void setCurrentPage(String page) {
    if (page != currentPage) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void setCurrentPageToStartupPage() {
    _currentPage = AppGlobal.startupPage;
    notifyListeners();
  }

  void showNavBottom() {
    if (!_isNavBottomVisible) {
      _isNavBottomVisible = true;
      notifyListeners();
    }
  }

  void hideNavBottom() {
    if (_isNavBottomVisible) {
      _isNavBottomVisible = false;
      notifyListeners();
    }
  }
}
