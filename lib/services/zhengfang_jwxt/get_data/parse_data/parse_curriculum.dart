import 'package:sachet/models/zhengfang_jwxt/response/curriculum_response_zf.dart';

/// 解析培养方案返回的课程信息
///
/// 返回： List<CurriculumResponseZF>
List<CurriculumResponseZF> parseCurriculumZF(Map jsonData) {
  List items = jsonData['items'];
  if (items.isEmpty) {
    throw '课程信息为空，没有符合条件记录!';
  }

  List<CurriculumResponseZF> curriculums = [];

  for (final item in items) {
    CurriculumResponseZF curriculum = CurriculumResponseZF.fromJson(item);
    curriculums.add(curriculum);
  }

  return curriculums;
}
