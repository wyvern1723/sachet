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
  bool? isEnableCaptchaRecognizer;
  String? navigationType;
  bool? isOpenLinkInExternalBrowser;
  bool? isUsingDynamicColors;
  String? pageTransition;
  bool? isPredictiveBack;
  bool? isFreeClassroomUseLegacyStyle;
  bool? isEnableCourseNotification;
  bool? isSilentNotification;
  List? freeClassroomSections;

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
    this.isEnableCaptchaRecognizer,
    this.navigationType,
    this.isOpenLinkInExternalBrowser,
    this.isUsingDynamicColors,
    this.pageTransition,
    this.isPredictiveBack,
    this.isFreeClassroomUseLegacyStyle,
    this.isEnableCourseNotification,
    this.isSilentNotification,
    this.freeClassroomSections,
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
    isEnableCaptchaRecognizer = json['isEnableCaptchaRecognizer'];
    navigationType = json['navigationType'];
    isOpenLinkInExternalBrowser = json['isOpenLinkInExternalBrowser'];
    isUsingDynamicColors = json['isUsingDynamicColors'];
    pageTransition = json['pageTransition'];
    isPredictiveBack = json['isPredictiveBack'];
    isFreeClassroomUseLegacyStyle = json['isFreeClassroomUseLegacyStyle'];
    isEnableCourseNotification = json['isEnableCourseNotification'];
    isSilentNotification = json['isSilentNotification'];
    freeClassroomSections = json['freeClassroomSections'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isMD3'] = this.isMD3;
    data['themeMode'] = this.themeMode;
    data['themeColor'] = this.themeColor;
    data['startupPage'] = this.startupPage;
    data['isAutoCheckUpdate'] = this.isAutoCheckUpdate;
    data['isShowAllCheckUpdateResult'] = this.isShowAllCheckUpdateResult;
    data['isShowPageTurnArrow'] = this.isShowPageTurnArrow;
    data['classScheduleFilePath'] = this.classScheduleFilePath;
    data['courseColorFilePath'] = this.courseColorFilePath;
    data['semesterStartDate'] = this.semesterStartDate;
    data['curveDuration '] = this.curveDuration;
    data['curveType'] = this.curveType;
    data['isEnableDevMode'] = this.isEnableDevMode;
    data['hasReadDisclaimer'] = this.hasReadDisclaimer;
    data['isEnableCaptchaRecognizer'] = this.isEnableCaptchaRecognizer;
    data['navigationType'] = this.navigationType;
    data['isOpenLinkInExternalBrowser'] = this.isOpenLinkInExternalBrowser;
    data['isUsingDynamicColors'] = this.isUsingDynamicColors;
    data['pageTransition'] = this.pageTransition;
    data['isPredictiveBack'] = this.isPredictiveBack;
    data['isFreeClassroomUseLegacyStyle'] = this.isFreeClassroomUseLegacyStyle;
    data['isEnableCourseNotification'] = this.isEnableCourseNotification;
    data['isSilentNotification'] = this.isSilentNotification;
    data['freeClassroomSections'] = this.freeClassroomSections;
    return data;
  }
}
