/// 正方教务系统的获取的一门课程的成绩信息
class GradeZf {
  /// 课程名称
  String courseTitle = '';

  /// 任课教师
  String instructor = '';

  /// 成绩
  String score = '';

  /// 绩点
  String gpa = '';

  /// 课程性质名称
  String courseType = '';

  GradeZf({
    required this.courseTitle,
    required this.instructor,
    required this.score,
    required this.gpa,
    required this.courseType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kcmc'] = courseTitle;
    data['czr'] = instructor;
    data['cj'] = score;
    data['jd'] = gpa;
    data['kcxzmc'] = courseType;
    return data;
  }

  GradeZf.fromJson(Map<String, dynamic> json) {
    courseTitle = json['kcmc'] ?? '';
    instructor = json['czr'] ?? '';
    score = json['cj'] ?? '';
    gpa = json['jd'] ?? '';
    courseType = json['kcxzmc'] ?? '';
  }
}
