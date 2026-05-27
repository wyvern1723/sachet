import 'models/grade_response_zf.dart';

/// 解析考试成绩数据
///
/// 返回： List<GradeZF> 各门课成绩的列表
List<GradeResponseZF> parseGradeZF(Map jsonData) {
  List items = jsonData['items'];
  if (items.isEmpty) {
    throw '成绩数据为空';
  }

  List<GradeResponseZF> gradeList = [];
  for (var e in items) {
    GradeResponseZF grade = GradeResponseZF.fromJson(e);

    gradeList.add(grade);
  }
  return gradeList;
}
