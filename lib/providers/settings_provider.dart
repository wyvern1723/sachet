import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/app_settings.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/models/enums/app_update_channel.dart';
import 'package:sachet/models/enums/nav_type.dart';
import 'package:sachet/models/course_reminder.dart';
import 'package:sachet/models/session_routine.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/utils/semester_utils.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';

class SettingsProvider extends ChangeNotifier {
  static AppSettings get _appSettings => AppGlobal.appSettings;

  String get startupPage => _appSettings.startupPage ?? '/class';
  static bool get isAutoCheckUpdate => _appSettings.isAutoCheckUpdate ?? true;
  static String get appUpdateChannel =>
      _appSettings.appUpdateChannel ?? AppUpdateChannel.wyvernlab.host;
  static bool get isShowAllCheckUpdateResult =>
      _appSettings.isShowAllCheckUpdateResult ?? false;
  bool get isShowPageTurnArrow => _appSettings.isShowPageTurnArrow ?? true;
  String get classScheduleFilePath => _appSettings.classScheduleFilePath ?? '';
  String get courseColorFilePath => _appSettings.courseColorFilePath ?? '';

  /// 空闲教室页面使用的学期开始日期（与课程表无关）
  ///
  /// 课程表使用 [classScheduleSemesterStartDate]
  static String get semesterStartDate =>
      _appSettings.semesterStartDate ??
      constSemesterStartDate.toIso8601String();
  static DateTime get semesterStartDateDateTime =>
      DateTime.tryParse(semesterStartDate) ?? constSemesterStartDate;

  /// 用户在导入课表时添加的新学期或调整应用内有的学期的开学日期，各个学期的开始日期
  static Map<String, dynamic> get _semesterStartDates =>
      _appSettings.semesterStartDates ?? {};

  /// 获取指定学期的开始日期。优先使用已储存的日期，其次使用应用内置的日期
  static DateTime? semesterStartDateOf(String semester) {
    final String? stored = _semesterStartDates[semester]?.toString();
    return (stored == null ? null : DateTime.tryParse(stored)) ??
        semesterToStartDate[semester];
  }

  /// 当前课程表文件对应的学期（无法从文件名识别时为空字符串）
  static String get classScheduleSemester {
    final String filePath = _appSettings.classScheduleFilePath ?? '';
    if (filePath.isEmpty) return '';
    return semesterFromFileName(filePath) ?? '';
  }

  /// 当前课程表所在学期的开始日期
  static DateTime get classScheduleSemesterStartDate =>
      semesterStartDateOf(classScheduleSemester) ?? semesterStartDateDateTime;

  int get curveDuration => _appSettings.curveDuration ?? 1500;
  String get curveType => _appSettings.curveType ?? 'Easing.standard';
  bool get isEnableDevMode => _appSettings.isEnableDevMode ?? false;
  bool get hasReadDisclaimer => _appSettings.hasReadDisclaimer ?? false;
  static String get navigationType =>
      _appSettings.navigationType ?? NavType.bottomNavigationBar.type;
  static bool get isOpenLinkInExternalBrowser =>
      _appSettings.isOpenLinkInExternalBrowser ?? false;
  bool get isFreeClassroomUseLegacyStyle =>
      _appSettings.isFreeClassroomUseLegacyStyle ?? true;
  bool get isEnableCourseNotification =>
      _appSettings.isEnableCourseNotification ?? false;
  bool get isSilentNotification => _appSettings.isSilentNotification ?? false;
  List<List<int>> get freeClassroomSections =>
      _appSettings.freeClassroomSections
          ?.map((innerList) => List<int>.from(innerList))
          .toList() ??
      [
        [1, 2],
        [3, 4],
        [5, 6],
        [7, 8],
        [9, 10, 11],
      ];
  bool get isShowExamTimeCountdown =>
      _appSettings.isShowExamTimeCountdown ?? true;

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

  void setAppUpdateChannel(String value) {
    if (value != appUpdateChannel) {
      _appSettings.appUpdateChannel = value;
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

  /// 设置当前进行的学期的学期开始日期
  void setSemesterStartDate(String value) {
    if (value != semesterStartDate) {
      _appSettings.semesterStartDate = value;
      AppGlobal.saveAppSettings();
      notifyListeners();
    }
  }

  /// 设置指定学期的学期开始日期（用于课程表）
  void setSemesterStartDateOf(String semester, DateTime date) {
    final Map<String, dynamic> map = Map.of(_semesterStartDates);
    map[semester] = date.toIso8601String();
    _appSettings.semesterStartDates = map;
    AppGlobal.saveAppSettings();
    notifyListeners();
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

  void toggleIsShowExamTimeCountdown() {
    final oldValue = isShowExamTimeCountdown;
    _appSettings.isShowExamTimeCountdown = !oldValue;
    AppGlobal.saveAppSettings();
    notifyListeners();
  }

  Map? courseColorData;

  Future refreshCourseColorData() async {
    courseColorData = await CachedDataStorage.getDecodedMap(
      courseColorFilePath,
    );
    notifyListeners();
  }

  Future<
      ({
        List<List<CourseSchedule>>? courseScheduleItemsList,
        Map courseColorData
      })> loadCourseScheduleData() async {
    List<List<CourseSchedule>>? courseScheduleItemsList;
    final jsonData = await CachedDataStorage.getDecodedList(
      classScheduleFilePath,
    );

    if (jsonData.isNotEmpty) {
      if (jsonData.length == 35) {
        courseScheduleItemsList = jsonData.map((e) {
          if (e is List) {
            return e.map((item) {
              if (item is Map<String, dynamic>) {
                return CourseSchedule.fromJson(item);
              } else if (item is Map) {
                return CourseSchedule.fromJson(Map<String, dynamic>.from(item));
              }
              return CourseSchedule();
            }).toList();
          }
          return <CourseSchedule>[];
        }).toList();
      }
    }

    courseColorData ??= await CachedDataStorage.getDecodedMap(
      courseColorFilePath,
    );

    return (
      courseScheduleItemsList: courseScheduleItemsList,
      courseColorData: courseColorData ?? {},
    );
  }

  /// 生成课程通知的信息 (CourseReminders)
  Future<List<CourseReminder>> generateCourseScheduleReminders() async {
    List courseScheduleItemsList = [];
    final jsonData = await CachedDataStorage.getDecodedList(
      classScheduleFilePath,
    );
    if (jsonData.isNotEmpty) {
      courseScheduleItemsList = jsonData;
      if (courseScheduleItemsList.length != 35) {
        throw '无有效课程表文件';
      }
    } else {
      throw '课程信息为空/无有效课程表文件';
    }
    List<CourseReminder> reminders = [];
    for (final courseScheduleItems in courseScheduleItemsList) {
      for (final courseScheduleItem in courseScheduleItems) {
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
          for (final courseWeek in courseWeeks) {
            final result = getWeekdayAndSessionFromItem(courseItem);
            final int courseWeekday = result.weekday;

            // 课程开始节次，有 1/3/5/7/9
            final int courseStartSession = result.session;

            /// 这节课的日期（如 2025-09-08 00:00:00，日期精确，时间为0点）
            final DateTime courseDate = getDateFromWeekCountAndWeekday(
              semesterStartDate: classScheduleSemesterStartDate,
              weekCount: courseWeek,
              weekday: courseWeekday,
            );

            final bool isStaggered =
                SessionRoutine.isStaggeredPlace(coursePlace);
            final String courseStartTimeStr =
                SessionRoutine(date: courseDate, isStaggered: isStaggered)
                    .startTimes[courseStartSession - 1];
            final String courseEndTimeStr =
                SessionRoutine(date: courseDate, isStaggered: isStaggered)
                    .endTimes[courseStartSession - 1 + courseLength - 1];

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
