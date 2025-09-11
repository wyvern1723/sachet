import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_teaching_buildings.dart';

/// 获取空闲教室可选的教学楼(不包括 "全部":"" )
///
/// return e.g.
///
/// {"北山画室": "209", "北山阶梯": "206", "材料大楼": "907", "测试中心": "902", "第二教学楼": "109"}
Future<Map<String, String>> getTeachingBuildingsZF({
  required String cookie,

  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年
  required String semesterYear,

  /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期
  required String semesterIndex,
}) async {
  final List result = await fetchTeachingBuildingsZF(
    cookie: cookie,
    semesterYear: semesterYear,
    semesterIndex: semesterIndex,
  );
  Map<String, String> teachingBuildingMap = {};
  for (var e in result) {
    String teachingBuildingName = e['JXLMC'];
    String teachingBuildingValue = e['JXLDM'];
    teachingBuildingMap.addAll({teachingBuildingName: teachingBuildingValue});
  }
  return teachingBuildingMap;
}
