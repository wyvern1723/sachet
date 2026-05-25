import 'package:sachet/models/zhengfang_jwxt/response/school_major_response_zf.dart';

/// 解析培养方案返回的学院下的专业列表
///
/// 返回： List<SchoolMajorResponseZF>
List<SchoolMajorResponseZF> parseCultivationSchoolMajorsZF(List jsonData) {
  List items = jsonData;
  if (items.isEmpty) {
    throw '此学院下属专业信息为空';
  }

  List<SchoolMajorResponseZF> majorsList = [];

  for (final item in items) {
    SchoolMajorResponseZF major = SchoolMajorResponseZF.fromJson(item);
    majorsList.add(major);
  }

  return majorsList;
}
