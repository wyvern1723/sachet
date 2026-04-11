import 'package:sachet/models/zhengfang_jwxt/response/exam_time_response_zf.dart';

/// 解析考试时间数据(正方教务)
///
/// 返回： List<ExamTimeZF> 各门课考试时间的列表
List<ExamTimeResponseZF> parseExamTimeZF(Map jsonData) {
  List items = jsonData['items'];
  if (items.isEmpty) {
    throw '考试时间数据为空';
  }

  List<ExamTimeResponseZF> examTimeList = [];
  for (var e in items) {
    ExamTimeResponseZF examTime = ExamTimeResponseZF.fromJson(e);

    examTimeList.add(examTime);
  }
  return examTimeList;
}
