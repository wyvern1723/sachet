import 'package:flutter/material.dart';
import 'package:sachet/models/app_settings.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeProvider extends ChangeNotifier {
  AppSettings get _appSettings => AppGlobal.appSettings;

  bool get isMD3 => _appSettings.isMD3 ?? false;
  bool get isUsingDynamicColors => _appSettings.isUsingDynamicColors ?? false;
  int get themeMode => _appSettings.themeMode ?? 0;
  Color get themeColor =>
      colorFromHex(_appSettings.themeColor ?? "#FF64C564") ?? Color(0xFF64C564);

  void setIsMD3(bool ismd3) {
    if (ismd3 != isMD3) {
      _appSettings.isMD3 = ismd3;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setThemeMode(int mode) {
    if (mode != themeMode) {
      _appSettings.themeMode = mode;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setThemeColor(Color color) {
    if (colorToHex(color) != _appSettings.themeColor) {
      _appSettings.themeColor = colorToHex(color);
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsUsingDynamicColors(bool isDynamicColors) {
    if (isDynamicColors != isUsingDynamicColors) {
      _appSettings.isUsingDynamicColors = isDynamicColors;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }
}

const intAndThemeMode = {
  0: "系统",
  1: '明亮',
  2: '黑暗',
};
