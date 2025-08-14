import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/models/app_settings.dart';
import 'package:sachet/models/course_card_settings.dart';
import 'package:sachet/providers/user_provider.dart';
import 'package:sachet/services/check_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppGlobal {
  static late SharedPreferences _prefs;
  static late AppSettings appSettings;
  static late CourseCardSettings courseCardSettings;
  static String startupPage = '/class';

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    // WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();

    // 获取 SharedPreferences 里储存的 AppSettings
    String? prefsAppSettings = _prefs.getString("appSettings");
    if (prefsAppSettings != null) {
      // prefAppSettings 存在，反序列化
      try {
        appSettings = AppSettings.fromJson(jsonDecode(prefsAppSettings));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      // prefAppSettings 不存在，可能是首次启动应用，写入默认设置
      appSettings = AppSettings.fromJson(defaultAppSettingsConfig);
      saveAppSettings();
    }

    startupPage = appSettings.startupPage ?? '/class';
    UserProvider.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appSettings.isAutoCheckUpdate == true) {
        autoCheckUpdate();
      }
      if (appSettings.hasReadDisclaimer != true) {
        NavigatorGlobal.showDisclaimerDialog();
      }
    });
    initCourseCardSettings();
  }

  static Future initCourseCardSettings() async {
    // 获取 SharedPreferences 里储存的 courseCardSettings
    String? prefsCourseCardSettings = _prefs.getString("courseCardSettings");
    if (prefsCourseCardSettings != null) {
      // prefCourseCardSettings 存在，反序列化
      try {
        courseCardSettings =
            CourseCardSettings.fromJson(jsonDecode(prefsCourseCardSettings));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      // prefCourseCardSettings 不存在，可能是首次启动应用，写入默认设置
      courseCardSettings =
          CourseCardSettings.fromJson(defaultCourseCardSettingsConfig);
      saveCourseCardSettings();
    }
  }

  // 持久化应用设置
  static void saveAppSettings() =>
      _prefs.setString("appSettings", jsonEncode(appSettings.toJson()));

  // 持久化课程卡片设置
  static void saveCourseCardSettings() => _prefs.setString(
      "courseCardSettings", jsonEncode(courseCardSettings.toJson()));
}

/// 默认应用设置
const defaultAppSettingsConfig = {
  "isMD3": false, // 是否启用 MD3 (Material Design 3)
  "themeMode": 0, // 主题模式（0: 系统, 1: light, 2: light）
  "themeColor": "#FF64C564", // 主题色(ARGB)
  "startupPage": "/class", // 启动页
  "isAutoCheckUpdate": true, // 是否自动检查更新
  "isShowAllCheckUpdateResult": false, // 是否显示检查更新所有结果（检查更新失败和已是最新版）
  "isShowPageTurnArrow": true, // 是否显示课程表上一周下一周的翻页箭头
  "isShowOccupiedOrEmptyText": true, // 空闲教室是否显示 空/满 的文字
  "classScheduleFilePath": "", // 当前使用的课程表文件路径
  "courseColorFilePath": "", // 当前使用的课程配色文件路径
  "semesterStartDate": "2025-02-17", // 学期开始日期
  "curveDuration ": 1500, // 课表翻页动画时长
  "curveType": "Easing.standard", // 课表翻页动画类型
  "isEnableDevMode": false, // 是否启用开发者模式
  "hasReadDisclaimer": false, // 是否阅读过声明
  "isEnableCaptchaRecognizer": true, // 是否启用图片验证码自动识别
  /*
  navigationType 可用的值：
  1. navigationDrawer
  2. bottomNavigationBar
  [Understanding navigation - Material Design](https://m2.material.io/design/navigation/understanding-navigation.html#lateral-navigation)
  */
  "navigationType": "navigationDrawer", // 应用导航方式（默认为抽屉式）
  "isOpenLinkInExternalBrowser": false, // 是否在外部浏览器打开链接。否则使用 Android Custom Tabs
  // 是否使用动态取色的颜色作为应用主题色
  //（官方叫[动态配色](https://developer.android.com/develop/ui/views/theming/dynamic-colors?hl=zh-cn)，但国内叫「动态取色」更多也更易理解）。默认不启用，因为国内魔改 Android 系统五花八门，不确定具体实现的效果，而且我不喜欢。
  "isUsingDynamicColors": false
};

// 默认课程卡片外观设置
const defaultCourseCardSettingsConfig = {
  "cardHeight": 65.0, // 卡片高度（每一小节， 1 / 11 ）
  "cardBorderRadius": 6.0, // 卡片圆角大小
  "cardMargin": 2.0, // 卡片间距
  "titleFontSize": 13.0, // 课程名称字体大小
  "placeFontSize": 12.0, // 上课地点字体大小
  "instructorFontSize": 12.0, // 授课教师字体大小
  "titleFontWeight": 7, // 课程名称字重
  "placeFontWeight": 4, // 上课地点字重
  "instructorFontWeight": 4, // 授课教师字重
  "titleMaxLines": 3, // 课程名称最大显示行数
  "placeMaxLines": 2, // 上课地点最大显示行数
  "instructorMaxLines": 2, // 授课教师最大显示行数
  "titleTextColor": "#F2FFFFFF", // 课程名称字体颜色 (ARGB)
  "placeTextColor":
      "#F2FFFFFF", // 上课地点字体颜色 (ARGB) Colors.white70.withOpacity(0.95).value, Color(0xf2ffffff).value
  "instructorTextColor": "#F2FFFFFF" // 授课教师字体颜色 (ARGB)
};

const curveTypes = {
  'Easing.emphasizedAccelerate': Easing.emphasizedAccelerate,
  'Easing.linear': Easing.linear,
  'Easing.standard': Easing.standard,
  'Easing.standardAccelerate': Easing.standardAccelerate,
  'Easing.standardDecelerate': Easing.standardDecelerate,
  'Easing.legacyDecelerate': Easing.legacyDecelerate,
  'Easing.legacyAccelerate': Easing.legacyAccelerate,
  'Easing.legacy': Easing.legacy,
  'Curves.fastLinearToSlowEaseIn': Curves.fastLinearToSlowEaseIn,
  'Curves.ease': Curves.ease,
  'Curves.easeIn': Curves.easeIn,
  'Curves.easeInToLinear': Curves.easeInToLinear,
  'Curves.easeInSine': Curves.easeInSine,
  'Curves.easeInQuad': Curves.easeInQuad,
  'Curves.easeInCubic': Curves.easeInCubic,
  'Curves.easeInQuart': Curves.easeInQuart,
  'Curves.easeInQuint': Curves.easeInQuint,
  'Curves.easeInExpo': Curves.easeInExpo,
  'Curves.easeInCirc': Curves.easeInCirc,
  'Curves.easeInBack': Curves.easeInBack,
  'Curves.easeOut': Curves.easeOut,
  'Curves.linearToEaseOut': Curves.linearToEaseOut,
  'Curves.easeOutSine': Curves.easeOutSine,
  'Curves.easeOutQuad': Curves.easeOutQuad,
  'Curves.easeOutCubic': Curves.easeOutCubic,
  'Curves.easeOutQuart': Curves.easeOutQuart,
  'Curves.easeOutQuint': Curves.easeOutQuint,
  'Curves.easeOutExpo': Curves.easeOutExpo,
  'Curves.easeOutCirc': Curves.easeOutCirc,
  'Curves.easeOutBack': Curves.easeOutBack,
  'Curves.easeInOut': Curves.easeInOut,
  'Curves.easeInOutSine': Curves.easeInOutSine,
  'Curves.easeInOutQuad': Curves.easeInOutQuad,
  'Curves.easeInOutCubic': Curves.easeInOutCubic,
  'Curves.easeInOutQuart': Curves.easeInOutQuart,
  'Curves.easeInOutQuint': Curves.easeInOutQuint,
  'Curves.easeInOutExpo': Curves.easeInOutExpo,
  'Curves.easeInOutCirc': Curves.easeInOutCirc,
  'Curves.easeInOutBack': Curves.easeInOutBack,
  'Curves.fastOutSlowIn': Curves.fastOutSlowIn,
  'Curves.slowMiddle': Curves.slowMiddle,
};
