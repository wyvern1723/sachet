import 'package:sachet/models/zhengfang_jwxt/response/queryable_major_response_zf.dart';

/// 解析培养方案返回的可查询培养方案（课程信息）的专业
///
/// 返回： List<QueryableMajorResponseZF>
List<QueryableMajorResponseZF> parseCultivationQueryableMajorsZF(Map jsonData) {
  List items = jsonData['items'];
  if (items.isEmpty) {
    throw '可查询专业为空，没有符合条件记录!';
  }

  List<QueryableMajorResponseZF> majorsList = [];

  for (final item in items) {
    QueryableMajorResponseZF major = QueryableMajorResponseZF.fromJson(item);
    majorsList.add(major);
  }

  return majorsList;
}
