// 课程信息的 class,只在初始从强智教务系统获取课程信息时使用
class CourseScheduleRawDataQZ {
  String? courseTitle;
  String? courseInstructor;
  String? coursePlace;
  int? courseLength;

  CourseScheduleRawDataQZ(
      {this.courseTitle,
      this.courseInstructor,
      this.coursePlace,
      this.courseLength});

  CourseScheduleRawDataQZ.fromJson(Map<String, dynamic> json) {
    courseTitle = json['courseTitle'];
    courseInstructor = json['courseInstructor'];
    coursePlace = json['coursePlace'];
    courseLength = json['courseLength'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['courseTitle'] = this.courseTitle;
    data['courseInstructor'] = this.courseInstructor;
    data['coursePlace'] = this.coursePlace;
    data['courseLength'] = this.courseLength;
    return data;
  }
}
