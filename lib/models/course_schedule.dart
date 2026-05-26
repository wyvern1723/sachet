class CourseSchedule {
  int? item;
  String? title;
  String? instructor;
  String? place;
  int? length;
  List? weeks;

  CourseSchedule({
    this.item,
    this.title,
    this.instructor,
    this.place,
    this.length,
    this.weeks,
  });

  CourseSchedule.fromJson(Map<String, dynamic> json) {
    item = json['item'];
    title = json['title'];
    instructor = json['instructor'];
    place = json['place'];
    length = json['length'];
    weeks = json['weeks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item'] = item;
    data['title'] = title;
    data['instructor'] = instructor;
    data['place'] = place;
    data['length'] = length;
    data['weeks'] = weeks;
    return data;
  }
}
