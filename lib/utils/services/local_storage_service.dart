import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> readData(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  dynamic value = prefs.get(key);
  return value;
}

Future<dynamic> saveData(String key, dynamic value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (value is int) {
    prefs.setInt(key, value);
  } else if (value is double) {
    prefs.setDouble(key, value);
  } else if (value is String) {
    prefs.setString(key, value);
  } else if (value is bool) {
    prefs.setBool(key, value);
  } else {
    // print("Invalid Type");
  }
}
