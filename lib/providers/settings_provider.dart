import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/app_settings.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/models/nav_type.dart';
import 'package:sachet/models/course_reminder.dart';
import 'package:sachet/pages/class_single_page.dart';
import 'package:sachet/services/time_manager.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';

class SettingsProvider extends ChangeNotifier {
  static AppSettings get _appSettings => AppGlobal.appSettings;

  String get startupPage => _appSettings.startupPage ?? '/class';
  static bool get isAutoCheckUpdate => _appSettings.isAutoCheckUpdate ?? true;
  static bool get isShowAllCheckUpdateResult =>
      _appSettings.isShowAllCheckUpdateResult ?? false;
  bool get isShowPageTurnArrow => _appSettings.isShowPageTurnArrow ?? true;
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
      _appSettings.navigationType ?? NavType.bottomNavigationBar.type;
  static bool get isOpenLinkInExternalBrowser =>
      _appSettings.isOpenLinkInExternalBrowser ?? false;
  bool get isFreeClassroomUseLegacyStyle =>
      _appSettings.isFreeClassroomUseLegacyStyle ?? true;
  bool get isEnableCourseNotification =>
      _appSettings.isEnableCourseNotification ?? false;
  bool get isSilentNotification => _appSettings.isSilentNotification ?? false;
  List get freeClassroomSections =>
      _appSettings.freeClassroomSections ??
      [
        [1, 2],
        [3, 4],
        [5, 6],
        [7, 8],
        [9, 10, 11],
      ];

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

  void setIsFreeClassroomUseLegacyStyle(bool value) {
    if (value != isFreeClassroomUseLegacyStyle) {
      _appSettings.isFreeClassroomUseLegacyStyle = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsEnableCourseNotification(bool value) {
    if (value != isEnableCourseNotification) {
      _appSettings.isEnableCourseNotification = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setIsSilentNotification(bool value) {
    if (value != isSilentNotification) {
      _appSettings.isSilentNotification = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  void setFreeClassroomSections(List value) {
    if (value != freeClassroomSections) {
      _appSettings.freeClassroomSections = value;
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

  /// 生成课程通知的信息 (CourseReminders)
  Future<List<CourseReminder>> generateCourseScheduleReminders() async {
    List courseScheduleItemsList = [];
    final rawData = await CachedDataStorage().getDecodedData(
      path: classScheduleFilePath,
      type: List,
    );
    if (rawData is List && rawData.isNotEmpty) {
      courseScheduleItemsList = rawData;
      if (courseScheduleItemsList.length != 35) {
        throw '无有效课程表文件';
      }
    } else {
      throw '课程信息为空/无有效课程表文件';
    }
    List<CourseReminder> reminders = [];
    for (var courseScheduleItems in courseScheduleItemsList) {
      for (var courseScheduleItem in courseScheduleItems) {
        CourseSchedule courseSchedule =
            CourseSchedule.fromJson(courseScheduleItem);

        final int? courseItem = courseSchedule.item;
        final String? courseTitle = courseSchedule.title;
        final String courseInstructor = courseSchedule.instructor ?? '';
        final String coursePlace = courseSchedule.place ?? '';
        final List? courseWeeks = courseSchedule.weeks;
        final int courseLength = courseSchedule.length ?? 2;

        if (courseTitle != null &&
            courseTitle.isNotEmpty &&
            courseWeeks != null &&
            courseWeeks.isNotEmpty &&
            courseItem != null) {
          for (var courseWeek in courseWeeks) {
            final result = _getWeekdayAndSessionFromItem(courseItem);
            final int courseWeekday = result.weekday;

            // 课程开始节次，有 1/3/5/7/9
            final int courseStartSession = result.session;

            /// 这节课的日期（如 2025-09-08 00:00:00，日期精确，时间为0点）
            final DateTime courseDate = getDateFromWeekCountAndWeekday(
              semesterStartDate: DateTime.tryParse(semesterStartDate) ??
                  constSemesterStartDate,
              weekCount: courseWeek,
              weekday: courseWeekday,
            );

            String courseStartTimeStr = '';
            String courseEndTimeStr = '';

            /// 是否是夏令时
            final bool isSummerRountine =
                courseDate.month > 4 && courseDate.month < 10;
            if (isSummerRountine) {
              courseStartTimeStr =
                  classSessionSummerRoutineStartTime[courseStartSession - 1];
              courseEndTimeStr = classSessionSummerRoutineEndTime[
                  courseStartSession - 1 + courseLength - 1];
            } else {
              courseStartTimeStr =
                  classSessionWinterRoutineStartTime[courseStartSession - 1];
              courseEndTimeStr = classSessionWinterRoutineEndTime[
                  courseStartSession - 1 + courseLength - 1];
            }

            /// 这节课的开始日期和时间（如 2025-09-08 08:00:00，日期精确，时间精确）
            final DateTime courseStartDateTime = courseDate.add(
              Duration(
                hours: int.parse(courseStartTimeStr.split(':')[0]),
                minutes: int.parse(courseStartTimeStr.split(':')[1]),
              ),
            );
            if (courseStartDateTime.isBefore(DateTime.now())) {
              // 如果这节课的开始时间在「现在」之前，则跳过（用户不一定是在学期开始即开启通知/使用本软件）
              continue;
            }

            final DateTime courseEndDateTime = courseDate.add(
              Duration(
                hours: int.parse(courseEndTimeStr.split(':')[0]),
                minutes: int.parse(courseEndTimeStr.split(':')[1]),
              ),
            );

            // 这节课上多久（用于通知经过多长时间后自动消失）
            final int courseDurationInMilliseconds = courseEndDateTime
                .difference(courseStartDateTime)
                .inMilliseconds;

            // 添加这个时段的课的一个周次的通知信息
            reminders.add(CourseReminder(
              courseStartDateTime: courseStartDateTime,
              courseDurationInMilliseconds: courseDurationInMilliseconds,
              courseTitle: courseTitle,
              coursePlace: coursePlace,
              courseInstructor: courseInstructor,
              courseStartTimeStr: courseStartTimeStr,
              courseEndTimeStr: courseEndTimeStr,
            ));
          }
        }
      }
    }
    return reminders;
  }
}

/// 从 item 得到 weekday 和 开始 session
///
/// 如 0 => weekday: 1, session: 1
///
/// 如 1 => weekday: 1, session: 3
///
/// 如 17 => weekday: 4, session: 5
///
/// 如 23 => weekday: 5, session: 7
///
/// 如 34 => weekday: 7, session: 9
///
/// ```
/// item:
///
///       Mon Tue Wed Thu Fri Sat Sun
/// 12      0   5  10  15  20  25  30
/// 34      1   6  11  16  21  26  31
/// 56      2   7  12  17  22  27  32
/// 78      3   8  13  18  23  28  33
/// 91011   4   9  14  19  24  29  34
/// ```
({int weekday, int session}) _getWeekdayAndSessionFromItem(int item) {
  final int session = [1, 3, 5, 7, 9][item % 5];
  return (weekday: (item ~/ 5) + 1, session: session);
}
