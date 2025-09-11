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
    classroomName = json['cdmc'] ?? '';
    seatAmount = json['zws'] ?? '';
    examSeatAmount = json['kszws1'] ?? '';
    teachingBuilding = json['jxlmc'] ?? '';
    placeType = json['cdlbmc'] ?? '';
    placeSubType = json['cdejlbmc'] ?? '';
  }

  item(String item) {
    switch (item) {
      case '场地名称':
        return this.classroomName;
      case '座位数':
        return this.seatAmount;
      case '考试座位数':
        return this.examSeatAmount;
      case '楼号':
        return this.teachingBuilding;
      case '场地类别':
        return this.placeType;
      case '场地二级类别':
        return this.placeSubType;
      default:
        return this.classroomName;
    }
  }
}
