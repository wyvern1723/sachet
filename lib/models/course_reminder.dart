class CourseReminder {
  /// 课程开始时间
  final DateTime courseStartDateTime;

  /// 通知发送时间
  ///
  /// 一般为「课程开始时间 - 提前通知的时间」；
  /// 如果这节课与上一节课是连着的课，则为上一节课的结束时间。
  final DateTime notificationDateTime;

  /// 这节课的持续时间/上多久（用于通知经过多长时间后自动消失）
  final int courseDurationInMilliseconds;

  /// 课程名称
  final String courseTitle;

  /// 上课地点
  final String coursePlace;

  /// 授课教师
  final String courseInstructor;

  /// 开始时间（如 "08:00"/"10:10")
  final String courseStartTimeStr;

  /// 结束时间（如 "08:45"/"10:55")
  final String courseEndTimeStr;

  CourseReminder({
    required this.courseStartDateTime,
    required this.notificationDateTime,
    required this.courseDurationInMilliseconds,
    required this.courseTitle,
    required this.coursePlace,
    required this.courseInstructor,
    required this.courseStartTimeStr,
    required this.courseEndTimeStr,
  });
}
