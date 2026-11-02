class CourseSchedule {
  int? item;

  /// 课程名称
  String? title;

  /// 上课教师/实验课指导教师
  String? instructor;

  /// 上课地点
  String? place;

  /// 课程持续长度，如1-2节是2节，3-4节是2节，9-11节是3节，1-4节是4节
  int? length;

  /// 上课周次，以 List<int> 储存
  List? weeks;

  /// 是否是实验课
  bool? isExperimentCourse;

  /// 实验项目名称
  String? experimentName;

  /// 实验分组名称
  String? experimentGroupName;

  CourseSchedule({
    this.item,
    this.title,
    this.instructor,
    this.place,
    this.length,
    this.weeks,
    this.isExperimentCourse,
    this.experimentName,
    this.experimentGroupName,
  });

  CourseSchedule.fromJson(Map<String, dynamic> json) {
    item = json['item'];
    title = json['title'];
    instructor = json['instructor'];
    place = json['place'];
    length = json['length'];
    weeks = json['weeks'];
    isExperimentCourse = json['isExperimentCourse'];
    experimentName = json['experimentName'];
    experimentGroupName = json['experimentGroupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item'] = item;
    data['title'] = title;
    data['instructor'] = instructor;
    data['place'] = place;
    data['length'] = length;
    data['weeks'] = weeks;
    data['isExperimentCourse'] = isExperimentCourse;
    data['experimentName'] = experimentName;
    data['experimentGroupName'] = experimentGroupName;
    return data;
  }
}
