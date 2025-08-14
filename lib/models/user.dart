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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['studentID'] = this.studentID;
    data['password'] = this.password;
    data['cookie'] = this.cookie;
    return data;
  }
}
