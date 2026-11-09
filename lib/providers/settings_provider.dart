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

  /// 课程通知提前的时间（分钟），连着的课不受此设置影响
  int get courseNotificationAdvanceMinutes =>
      _appSettings.courseNotificationAdvanceMinutes ??
      defaultCourseNotificationAdvanceMinutes;

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

  void setCourseNotificationAdvanceMinutes(int value) {
    if (value != courseNotificationAdvanceMinutes) {
      _appSettings.courseNotificationAdvanceMinutes = value;
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

    final Duration advanceDuration =
        Duration(minutes: courseNotificationAdvanceMinutes);

    // 收集所有课程（每个周次、每个星期几的一节课）
    final List<_CourseInstance> courseInstances = [];
    for (final courseScheduleItems in courseScheduleItemsList) {
      for (final courseScheduleItem in courseScheduleItems) {
        final CourseSchedule courseSchedule =
            CourseSchedule.fromJson(courseScheduleItem);

        final int? courseItem = courseSchedule.item;
        final String? courseTitle = courseSchedule.title;
        final String courseInstructor = courseSchedule.instructor ?? '';
        final String coursePlace = courseSchedule.place ?? '';
        final List? courseWeeks = courseSchedule.weeks;
        final int courseLength = courseSchedule.length ?? 2;

        if (courseTitle == null ||
            courseTitle.isEmpty ||
            courseWeeks == null ||
            courseWeeks.isEmpty ||
            courseItem == null) {
          continue;
        }

        final weekdayAndSession = getWeekdayAndSessionFromItem(courseItem);
        final int courseWeekday = weekdayAndSession.weekday;

        // 课程开始节次
        final int courseStartSession = weekdayAndSession.session;

        // 课程结束节次
        final int courseEndSession = courseStartSession + courseLength - 1;

        final bool isStaggered = SessionRoutine.isStaggeredPlace(coursePlace);

        for (final courseWeek in courseWeeks) {
          final DateTime courseDate = getDateFromWeekCountAndWeekday(
            semesterStartDate: classScheduleSemesterStartDate,
            weekCount: courseWeek,
            weekday: courseWeekday,
          );
          final SessionRoutine routine =
              SessionRoutine(date: courseDate, isStaggered: isStaggered);

          final String courseStartTimeStr =
              routine.startTimes[courseStartSession - 1];
          final String courseEndTimeStr =
              routine.endTimes[courseEndSession - 1];

          courseInstances.add(_CourseInstance(
            weekCount: courseWeek,
            weekday: courseWeekday,
            startSession: courseStartSession,
            endSession: courseEndSession,
            startDateTime: _combineDateAndTime(courseDate, courseStartTimeStr),
            endDateTime: _combineDateAndTime(courseDate, courseEndTimeStr),
            title: courseTitle,
            place: coursePlace,
            instructor: courseInstructor,
            startTimeStr: courseStartTimeStr,
            endTimeStr: courseEndTimeStr,
          ));
        }
      }
    }

    // 按「周次 -> 星期几 -> 开始节次」排序，顺序遍历即可判断相邻课程是否连着
    courseInstances.sort((a, b) {
      if (a.weekCount != b.weekCount) {
        return a.weekCount.compareTo(b.weekCount);
      }
      if (a.weekday != b.weekday) return a.weekday.compareTo(b.weekday);
      return a.startSession.compareTo(b.startSession);
    });

    final DateTime now = DateTime.now();
    final List<CourseReminder> reminders = [];
    _CourseInstance? previousCourse;

    for (final courseInstance in courseInstances) {
      // 默认提前 [advanceDuration] 提醒
      DateTime notificationDateTime =
          courseInstance.startDateTime.subtract(advanceDuration);

      if (previousCourse != null &&
          previousCourse.weekCount == courseInstance.weekCount &&
          previousCourse.weekday == courseInstance.weekday &&
          // 上一节课的下一节就是下一节课的开始
          previousCourse.endSession + 1 == courseInstance.startSession &&
          // 午休（第 4 节 -> 第 5 节）和晚休（第 8 节 -> 第 9 节）不算连着的课
          previousCourse.endSession != 4 &&
          previousCourse.endSession != 8) {
        // 连着的课在上一节课结束时提醒
        notificationDateTime = previousCourse.endDateTime;
      }

      // 提醒时间已经过去（例如在上一节课结束后才开启通知）时立即提醒
      if (notificationDateTime.isBefore(now)) {
        notificationDateTime = now;
      }

      // 跳过已经开始过的课程（用户不一定是在学期开始即开启通知/使用本软件）
      final bool hasCourseStarted = courseInstance.startDateTime.isBefore(now);
      previousCourse = courseInstance;
      if (hasCourseStarted) continue;

      reminders.add(CourseReminder(
        courseStartDateTime: courseInstance.startDateTime,
        notificationDateTime: notificationDateTime,
        courseDurationInMilliseconds: courseInstance.endDateTime
            .difference(courseInstance.startDateTime)
            .inMilliseconds,
        courseTitle: courseInstance.title,
        coursePlace: courseInstance.place,
        courseInstructor: courseInstance.instructor,
        courseStartTimeStr: courseInstance.startTimeStr,
        courseEndTimeStr: courseInstance.endTimeStr,
      ));
    }
    return reminders;
  }

  /// 将日期和时间字符串（如 "08:00"）组合为 DateTime
  static DateTime _combineDateAndTime(DateTime date, String timeStr) {
    final List<String> parts = timeStr.split(':');
    return date.add(Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
    ));
  }
}

/// 某周、某天的具体一节课（含节次与起止时间）
class _CourseInstance {
  const _CourseInstance({
    required this.weekCount,
    required this.weekday,
    required this.startSession,
    required this.endSession,
    required this.startDateTime,
    required this.endDateTime,
    required this.title,
    required this.place,
    required this.instructor,
    required this.startTimeStr,
    required this.endTimeStr,
  });

  final int weekCount;
  final int weekday;
  final int startSession;
  final int endSession;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String title;
  final String place;
  final String instructor;
  final String startTimeStr;
  final String endTimeStr;
}
