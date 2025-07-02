import 'package:flutter/material.dart';
import 'package:sachet/provider/app_global.dart';

class ScreenNavProvider extends ChangeNotifier {
  static String _currentPage = AppGlobal.startupPage;
  static String get currentPage => _currentPage;

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
}
