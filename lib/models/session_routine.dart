/// 每节课的节次、上课时间和结束时间
class SessionPeriod {
  const SessionPeriod({
    required this.session,
    required this.startTime,
    required this.endTime,
  });
  final int session;
  final String startTime;
  final String endTime;
}

/// 课程时间表
class SessionRoutine {
  const SessionRoutine._(this.periods);

  factory SessionRoutine({
    required DateTime date,
    bool isStaggered = false,
  }) {
    if (isSummer(date)) return summer;

    if (isBeforeStaggeredStartDate(date)) return winterPre2026;

    return isStaggered ? winterStaggered : winterRegular;
  }

  final List<SessionPeriod> periods;

  /// 是否是夏季作息（5–9 月）
  static bool isSummer(DateTime date) => date.month > 4 && date.month < 10;

  /// 这节课的日期是否还在试行错峰上课方案的开始日期之前
  static bool isBeforeStaggeredStartDate(DateTime date) =>
      date.isBefore(DateTime(2026, 10, 1));

  /// 上课地点是否属于需要错峰上课的教学楼
  /// [关于试行错峰上课的通知-政务信息港](https://zwxxg.xtu.edu.cn/content.jsp?urltype=news.NewsContentUrl&wbtreeid=1066&wbnewsid=10705)
  static bool isStaggeredPlace(String place) =>
      (place.contains('逸夫楼') || place.contains('信息科技大楼'));

  List<String> get startTimes => [for (final p in periods) p.startTime];
  List<String> get endTimes => [for (final p in periods) p.endTime];

  /// 夏季作息时，每节课的开始和结束时间
  static const summer = SessionRoutine._(<SessionPeriod>[
    SessionPeriod(session: 1, startTime: '08:00', endTime: '08:45'),
    SessionPeriod(session: 2, startTime: '08:55', endTime: '09:40'),
    SessionPeriod(session: 3, startTime: '10:10', endTime: '10:55'),
    SessionPeriod(session: 4, startTime: '11:05', endTime: '11:50'),
    SessionPeriod(session: 5, startTime: '14:30', endTime: '15:15'),
    SessionPeriod(session: 6, startTime: '15:25', endTime: '16:10'),
    SessionPeriod(session: 7, startTime: '16:40', endTime: '17:25'),
    SessionPeriod(session: 8, startTime: '17:35', endTime: '18:20'),
    SessionPeriod(session: 9, startTime: '19:30', endTime: '20:15'),
    SessionPeriod(session: 10, startTime: '20:25', endTime: '21:10'),
    SessionPeriod(session: 11, startTime: '21:20', endTime: '22:05'),
  ]);

  /// 冬季作息时，每节课的开始和结束时间（在 2026年10月1日 试行错峰上课之前使用，不清楚最早是什么时候使用这个时间表，应该很多年了）
  static const winterPre2026 = SessionRoutine._(<SessionPeriod>[
    SessionPeriod(session: 1, startTime: '08:00', endTime: '08:45'),
    SessionPeriod(session: 2, startTime: '08:55', endTime: '09:40'),
    SessionPeriod(session: 3, startTime: '10:10', endTime: '10:55'),
    SessionPeriod(session: 4, startTime: '11:05', endTime: '11:50'),
    SessionPeriod(session: 5, startTime: '14:00', endTime: '14:45'),
    SessionPeriod(session: 6, startTime: '14:55', endTime: '15:40'),
    SessionPeriod(session: 7, startTime: '16:10', endTime: '16:55'),
    SessionPeriod(session: 8, startTime: '17:05', endTime: '17:50'),
    SessionPeriod(session: 9, startTime: '19:00', endTime: '19:45'),
    SessionPeriod(session: 10, startTime: '19:55', endTime: '20:40'),
    SessionPeriod(session: 11, startTime: '20:50', endTime: '21:35'),
  ]);

  /// 冬季作息时，非错峰教学楼的每节课的开始和结束时间（在 2026年10月1日 试行错峰上课之后使用）
  static const winterRegular = SessionRoutine._(<SessionPeriod>[
    SessionPeriod(session: 1, startTime: '08:00', endTime: '08:45'),
    SessionPeriod(session: 2, startTime: '08:55', endTime: '09:40'),
    SessionPeriod(session: 3, startTime: '10:20', endTime: '11:05'),
    SessionPeriod(session: 4, startTime: '11:15', endTime: '12:00'),
    SessionPeriod(session: 5, startTime: '14:00', endTime: '14:45'),
    SessionPeriod(session: 6, startTime: '14:55', endTime: '15:40'),
    SessionPeriod(session: 7, startTime: '16:20', endTime: '17:05'),
    SessionPeriod(session: 8, startTime: '17:15', endTime: '18:00'),
    SessionPeriod(session: 9, startTime: '19:15', endTime: '20:00'),
    SessionPeriod(session: 10, startTime: '20:10', endTime: '20:55'),
    SessionPeriod(session: 11, startTime: '21:05', endTime: '21:50'),
  ]);

  /// 冬季作息时，错峰教学楼的每节课的开始和结束时间（在 2026年10月1日 试行错峰上课之后使用）
  static const winterStaggered = SessionRoutine._(<SessionPeriod>[
    SessionPeriod(session: 1, startTime: '08:10', endTime: '08:55'),
    SessionPeriod(session: 2, startTime: '09:05', endTime: '09:50'),
    SessionPeriod(session: 3, startTime: '10:30', endTime: '11:15'),
    SessionPeriod(session: 4, startTime: '11:25', endTime: '12:10'),
    SessionPeriod(session: 5, startTime: '14:10', endTime: '14:55'),
    SessionPeriod(session: 6, startTime: '15:05', endTime: '15:50'),
    SessionPeriod(session: 7, startTime: '16:30', endTime: '17:15'),
    SessionPeriod(session: 8, startTime: '17:25', endTime: '18:10'),
    SessionPeriod(session: 9, startTime: '19:15', endTime: '20:00'),
    SessionPeriod(session: 10, startTime: '20:10', endTime: '20:55'),
    SessionPeriod(session: 11, startTime: '21:05', endTime: '21:50'),
  ]);
}
