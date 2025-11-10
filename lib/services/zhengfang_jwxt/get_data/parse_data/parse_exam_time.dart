import 'package:sachet/models/exam_time_zf.dart';

/// 解析考试时间数据(正方教务)
///
/// 返回： List<ExamTimeZF> 各门课考试时间的列表
List<ExamTimeZF> parseExamTimeZF(Map jsonData) {
  List items = jsonData['items'];
  if (items.isEmpty) {
    throw '考试时间数据为空';
  }

  List<ExamTimeZF> examTimeList = [];
  for (var e in items) {
    ExamTimeZF examTime = ExamTimeZF.fromJson(e);

    examTimeList.add(examTime);
  }
  return examTimeList;
}
