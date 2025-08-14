class CourseSchedule {
  int? item;
  String? title;
  String? instructor;
  String? place;
  int? length;
  List? weeks;

  CourseSchedule(
      {this.item,
      this.title,
      this.instructor,
      this.place,
      this.length,
      this.weeks});

  CourseSchedule.fromJson(Map<String, dynamic> json) {
    item = json['item'];
    title = json['title'];
    instructor = json['instructor'];
    place = json['place'];
    length = json['length'];
    weeks = json['weeks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item'] = this.item;
    data['title'] = this.title;
    data['instructor'] = this.instructor;
    data['place'] = this.place;
    data['length'] = this.length;
    data['weeks'] = this.weeks;
    return data;
  }
}
