import 'package:sachet/utils/json_safe_parse.dart';

/// 从正方教务系统获取的空闲教室中的一个教室的信息
class FreeClassroomDataZF {
  /// 教室名称
  String classroomName = '';

  /// 座位数
  String seatAmount = '';

  /// 考试座位数
  String examSeatAmount = '';

  /// 楼号（教室所属教学楼）
  String teachingBuilding = '';

  /// 场地类别
  String placeType = '';

  /// 场地二级类别
  String placeSubType = '';

  FreeClassroomDataZF({
    required this.classroomName,
    required this.seatAmount,
    required this.examSeatAmount,
    required this.teachingBuilding,
    required this.placeType,
  });

  FreeClassroomDataZF.fromJson(Map<String, dynamic> json) {
    classroomName = json.safeString('cdmc') ?? '';
    seatAmount = json.safeString('zws') ?? '';
    examSeatAmount = json.safeString('kszws1') ?? '';
    teachingBuilding = json.safeString('jxlmc') ?? '';
    placeType = json.safeString('cdlbmc') ?? '';
    placeSubType = json.safeString('cdejlbmc') ?? '';
  }

  item(String item) {
    switch (item) {
      case '场地名称':
        return classroomName;
      case '座位数':
        return seatAmount;
      case '考试座位数':
        return examSeatAmount;
      case '楼号':
        return teachingBuilding;
      case '场地类别':
        return placeType;
      case '场地二级类别':
        return placeSubType;
      default:
        return classroomName;
    }
  }
}
