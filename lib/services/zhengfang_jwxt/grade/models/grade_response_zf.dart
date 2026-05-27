import 'package:sachet/utils/json_safe_parse.dart';

/// 从正方教务系统获取的一门课程的成绩信息
class GradeResponseZF {
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

  /// 学分
  String credit = '';

  /// 学年名（2024-2025）
  String semesterYear = '';

  /// 学期名（1/2/3）
  String semesterIndex = '';

  GradeResponseZF({
    required this.courseTitle,
    required this.instructor,
    required this.score,
    required this.gpa,
    required this.courseType,
    required this.credit,
    required this.semesterYear,
    required this.semesterIndex,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kcmc'] = courseTitle;
    data['czr'] = instructor;
    data['cj'] = score;
    data['jd'] = gpa;
    data['kcxzmc'] = courseType;
    data['xf'] = credit;
    data['xnmmc'] = semesterYear;
    data['xqmmc'] = semesterIndex;
    return data;
  }

  GradeResponseZF.fromJson(Map<String, dynamic> json) {
    courseTitle = json.safeString('kcmc') ?? '';
    instructor = json.safeString('czr') ?? '';
    score = json.safeString('cj') ?? '';
    gpa = json.safeString('jd') ?? '';
    courseType = json.safeString('kcxzmc') ?? '';
    credit = json.safeString('xf') ?? '';
    semesterYear = json.safeString('xnmmc') ?? '';
    semesterIndex = json.safeString('xqmmc') ?? '';
  }

  item(String item) {
    switch (item) {
      case '课程名称':
        return courseTitle;
      case '任课教师':
        return instructor;
      case '成绩':
        return score;
      case '绩点':
        return gpa;
      case '学分':
        return credit;
      case '课程性质':
        return courseType;
      case '学期':
        return '$semesterYear-$semesterIndex';
      default:
        return courseTitle;
    }
  }
}
