class AppSettings {
  bool? isMD3;
  int? themeMode;
  String? themeColor;
  String? startupPage;
  bool? isAutoCheckUpdate;
  bool? isShowAllCheckUpdateResult;
  bool? isShowPageTurnArrow;
  String? classScheduleFilePath;
  String? courseColorFilePath;
  String? semesterStartDate;
  int? curveDuration;
  String? curveType;
  bool? isEnableDevMode;
  bool? hasReadDisclaimer;
  String? navigationType;
  bool? isOpenLinkInExternalBrowser;
  bool? isUsingDynamicColors;
  String? pageTransition;
  bool? isPredictiveBack;
  bool? isFreeClassroomUseLegacyStyle;
  bool? isEnableCourseNotification;
  bool? isSilentNotification;
  List? freeClassroomSections;
  bool? isShowExamTimeCountdown;
  bool? isDeleteQZJwxtUserInfo;

  AppSettings({
    this.isMD3,
    this.themeMode,
    this.themeColor,
    this.startupPage,
    this.isAutoCheckUpdate,
    this.isShowAllCheckUpdateResult,
    this.isShowPageTurnArrow,
    this.classScheduleFilePath,
    this.courseColorFilePath,
    this.semesterStartDate,
    this.curveDuration,
    this.curveType,
    this.isEnableDevMode,
    this.hasReadDisclaimer,
    this.navigationType,
    this.isOpenLinkInExternalBrowser,
    this.isUsingDynamicColors,
    this.pageTransition,
    this.isPredictiveBack,
    this.isFreeClassroomUseLegacyStyle,
    this.isEnableCourseNotification,
    this.isSilentNotification,
    this.freeClassroomSections,
    this.isShowExamTimeCountdown,
    this.isDeleteQZJwxtUserInfo,
  });

  AppSettings.fromJson(Map<String, dynamic> json) {
    isMD3 = json['isMD3'];
    themeMode = json['themeMode'];
    themeColor = json['themeColor'];
    startupPage = json['startupPage'];
    isAutoCheckUpdate = json['isAutoCheckUpdate'];
    isShowAllCheckUpdateResult = json['isShowAllCheckUpdateResult'];
    isShowPageTurnArrow = json['isShowPageTurnArrow'];
    classScheduleFilePath = json['classScheduleFilePath'];
    courseColorFilePath = json['courseColorFilePath'];
    semesterStartDate = json['semesterStartDate'];
    curveDuration = json['curveDuration '];
    curveType = json['curveType'];
    isEnableDevMode = json['isEnableDevMode'];
    hasReadDisclaimer = json['hasReadDisclaimer'];
    navigationType = json['navigationType'];
    isOpenLinkInExternalBrowser = json['isOpenLinkInExternalBrowser'];
    isUsingDynamicColors = json['isUsingDynamicColors'];
    pageTransition = json['pageTransition'];
    isPredictiveBack = json['isPredictiveBack'];
    isFreeClassroomUseLegacyStyle = json['isFreeClassroomUseLegacyStyle'];
    isEnableCourseNotification = json['isEnableCourseNotification'];
    isSilentNotification = json['isSilentNotification'];
    freeClassroomSections = json['freeClassroomSections'];
    isShowExamTimeCountdown = json['isShowExamTimeCountdown'];
    isDeleteQZJwxtUserInfo = json['isDeleteQZJwxtUserInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isMD3'] = isMD3;
    data['themeMode'] = themeMode;
    data['themeColor'] = themeColor;
    data['startupPage'] = startupPage;
    data['isAutoCheckUpdate'] = isAutoCheckUpdate;
    data['isShowAllCheckUpdateResult'] = isShowAllCheckUpdateResult;
    data['isShowPageTurnArrow'] = isShowPageTurnArrow;
    data['classScheduleFilePath'] = classScheduleFilePath;
    data['courseColorFilePath'] = courseColorFilePath;
    data['semesterStartDate'] = semesterStartDate;
    data['curveDuration '] = curveDuration;
    data['curveType'] = curveType;
    data['isEnableDevMode'] = isEnableDevMode;
    data['hasReadDisclaimer'] = hasReadDisclaimer;
    data['navigationType'] = navigationType;
    data['isOpenLinkInExternalBrowser'] = isOpenLinkInExternalBrowser;
    data['isUsingDynamicColors'] = isUsingDynamicColors;
    data['pageTransition'] = pageTransition;
    data['isPredictiveBack'] = isPredictiveBack;
    data['isFreeClassroomUseLegacyStyle'] = isFreeClassroomUseLegacyStyle;
    data['isEnableCourseNotification'] = isEnableCourseNotification;
    data['isSilentNotification'] = isSilentNotification;
    data['freeClassroomSections'] = freeClassroomSections;
    data['isShowExamTimeCountdown'] = isShowExamTimeCountdown;
    data['isDeleteQZJwxtUserInfo'] = isDeleteQZJwxtUserInfo;
    return data;
  }
}
