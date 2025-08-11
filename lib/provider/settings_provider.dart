import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/pages/class_single_page.dart';
import 'package:sachet/provider/app_global.dart';
import 'package:sachet/utils/services/path_provider_service.dart';

class SettingsProvider extends ChangeNotifier {
  static AppSettings get _appSettings => AppGlobal.appSettings;

  String get startupPage => _appSettings.startupPage ?? '/class';
  static bool get isAutoCheckUpdate => _appSettings.isAutoCheckUpdate ?? true;
  static bool get isShowAllCheckUpdateResult =>
      _appSettings.isShowAllCheckUpdateResult ?? false;
  bool get isShowPageTurnArrow => _appSettings.isShowPageTurnArrow ?? true;
  bool get isShowOccupiedOrEmptyText =>
      _appSettings.isShowOccupiedOrEmptyText ?? false;
  String get classScheduleFilePath => _appSettings.classScheduleFilePath ?? '';
  String get courseColorFilePath => _appSettings.courseColorFilePath ?? '';
  static String get semesterStartDate =>
      _appSettings.semesterStartDate ??
      constSemesterStartDate.toIso8601String();
  int get curveDuration => _appSettings.curveDuration ?? 1500;
  String get curveType => _appSettings.curveType ?? 'Easing.standard';
  bool get isEnableDevMode => _appSettings.isEnableDevMode ?? false;
  bool get hasReadDisclaimer => _appSettings.hasReadDisclaimer ?? false;
  static bool get isEnableCaptchaRecognizer =>
      _appSettings.isEnableCaptchaRecognizer ?? true;
  static String get navigationType =>
      _appSettings.navigationType ?? NavType.navigationDrawer.type;
  static bool get isOpenLinkInExternalBrowser =>
      _appSettings.isOpenLinkInExternalBrowser ?? false;

  void setStartupPage(String value) {
    if (value != startupPage) {
      _appSettings.startupPage = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsAutoCheckUpdate(bool value) {
    if (value != isAutoCheckUpdate) {
      _appSettings.isAutoCheckUpdate = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsShowUpdateFailedResult(bool value) {
    if (value != isShowAllCheckUpdateResult) {
      _appSettings.isShowAllCheckUpdateResult = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsShowPageTurnArrow(bool value) {
    if (value != isShowPageTurnArrow) {
      _appSettings.isShowPageTurnArrow = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsShowOccupiedOrEmptyText(bool value) {
    if (value != isShowOccupiedOrEmptyText) {
      _appSettings.isShowOccupiedOrEmptyText = value;
    }
    AppGlobal.saveAppSettings();
    notifyListeners();
  }

  void toggleIsShowOccupiedOrEmptyText() {
    _appSettings.isShowOccupiedOrEmptyText = !isShowOccupiedOrEmptyText;
    AppGlobal.saveAppSettings();
    notifyListeners();
  }

  void setClassScheduleFilePath(String value) {
    if (value != classScheduleFilePath) {
      _appSettings.classScheduleFilePath = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  Future setCourseColorFilePath(String value) async {
    if (value != courseColorFilePath) {
      _appSettings.courseColorFilePath = value;
      AppGlobal.saveAppSettings();
      await refreshCourseColorData();
    }
  }

  void setSemesterStartDate(String value) {
    if (value != semesterStartDate) {
      _appSettings.semesterStartDate = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setCurveDuration(int value) {
    if (value != curveDuration) {
      _appSettings.curveDuration = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setCurveType(String value) {
    if (value != curveType) {
      _appSettings.curveType = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void enableDevMode() {
    if (isEnableDevMode != true) {
      _appSettings.isEnableDevMode = true;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void disableDevMode() {
    if (isEnableDevMode != false) {
      _appSettings.isEnableDevMode = false;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setHasReadDisclaimer() {
    _appSettings.hasReadDisclaimer = true;
    AppGlobal.saveAppSettings();
    notifyListeners();
  }

  void setIsEnableCaptchaRecognizer(bool value) {
    if (value != isEnableCaptchaRecognizer) {
      _appSettings.isEnableCaptchaRecognizer = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setNavigationType(String value) {
    if (value != navigationType) {
      _appSettings.navigationType = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsOpenLinkInExternalBrowser(bool value) {
    if (value != isOpenLinkInExternalBrowser) {
      _appSettings.isOpenLinkInExternalBrowser = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  Map? courseColorData;

  Future refreshCourseColorData() async {
    courseColorData = await CachedDataStorage().getDecodedData(
      path: courseColorFilePath,
      type: Map,
    );
    notifyListeners();
  }

  /// 加载夏季作息的课程时间数据
  static Future<List> loadClassSessionSummerAsset() async {
    String data = await rootBundle
        .loadString('assets/json/ClassSessionSummerRoutine.json');
    List listData = jsonDecode(data);
    return listData;
  }

  /// 加载冬季作息的课程时间加载课表数据
  static Future<List> loadClassSessionWinterAsset() async {
    String data = await rootBundle
        .loadString('assets/json/ClassSessionWinterRoutine.json');
    List listData = jsonDecode(data);
    return listData;
  }

  Future<List<Widget>> generatePageList() async {
    List? courseScheduleItemsList;
    var rawData = await CachedDataStorage().getDecodedData(
      path: classScheduleFilePath,
      type: List,
    );

    if (rawData is List && rawData.isNotEmpty) {
      courseScheduleItemsList = rawData;

      if (courseScheduleItemsList.length != 35) {
        courseScheduleItemsList = null;
      }
    }
    if (courseColorData == null) {
      courseColorData = await CachedDataStorage().getDecodedData(
        path: courseColorFilePath,
        type: Map,
      );
    }
    List classSessionSummerDataList = await loadClassSessionSummerAsset();
    List classSessionWinterDataList = await loadClassSessionWinterAsset();
    List<Widget> pageList = [];
    for (int i = 1; i < 21; i++) {
      pageList.add(ClassSinglePage(
        weekCount: i,
        courseScheduleItemsList: courseScheduleItemsList,
        courseColorData: courseColorData ?? {},
        classSessionSummerDataList: classSessionSummerDataList,
        classSessionWinterDataList: classSessionWinterDataList,
      ));
    }
    return pageList;
  }
}
