class User {
  String? name;
  String? studentID;
  String? password;
  String? cookie;

  User({this.name, this.studentID, this.password, this.cookie});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    studentID = json['studentID'];
    password = json['password'];
    cookie = json['cookie'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['studentID'] = studentID;
    data['password'] = password;
    data['cookie'] = cookie;
    return data;
  }
}
