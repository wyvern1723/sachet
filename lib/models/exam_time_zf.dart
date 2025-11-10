/// 正方教务系统的获取的一门课程的成绩信息
class ExamTimeZF {
  /// 学年（2024-2025）
  String semesterYear = '';

  /// 学期（1/2/3）
  String semesterIndex = '';

  /// 课程名称，
  String courseTitle = '';

  /// 考试名称，如："（本部）2025-2026第一学期课程考试"
  String examName = '';

  /// 教师信息
  String instructorInfo = '';

  /// 考试地点
  String place = '';

  /// 场地简称
  String placeShort = '';

  /// 考试校区
  String campus = '';

  /// 考试时间
  String time = '';

  /// 开课学院
  String college = '';

  ExamTimeZF({
    required this.semesterYear,
    required this.semesterIndex,
    required this.courseTitle,
    required this.examName,
    required this.instructorInfo,
    required this.place,
    required this.placeShort,
    required this.campus,
    required this.time,
    required this.college,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['xnmc'] = semesterYear;
    data['xqmmc'] = semesterIndex;
    data['kcmc'] = courseTitle;
    data['ksmc'] = examName;
    data['jsxx'] = instructorInfo;
    data['cdmc'] = place;
    data['cdjc'] = placeShort;
    data['cdxqmc'] = campus;
    data['kssj'] = time;
    data['kkxy'] = college;
    return data;
  }

  ExamTimeZF.fromJson(Map<String, dynamic> json) {
    semesterYear = json['xnmmc'] ?? '';
    semesterIndex = json['xqmmc'] ?? '';
    courseTitle = json['kcmc'] ?? '';
    examName = json['ksmc'] ?? '';
    instructorInfo = json['jsxx'] ?? '';
    place = json['cdmc'] ?? '';
    placeShort = json['cdjc'] ?? '';
    campus = json['cdxqmc'] ?? '';
    time = json['kssj'] ?? '';
    college = json['kkxy'] ?? '';
  }
}
