import 'package:sachet/model/get_web_data/process_data/get_class_schedule.dart';

class CourseModel {
  List getWeeksOfCourse({
    required String title,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList =
        courseScheduleItems.where((element) => element.title == title).toList();
    if (elementList.isEmpty) {
      return [];
    } else {
      List weeks = [];
      elementList.forEach((element) {
        List? elementWeeks = element.weeks;
        if (elementWeeks != null && elementWeeks.isNotEmpty) {
          elementWeeks.forEach((week) => weeks.add(week));
        }
      });
      return weeks;
    }
  }

  List getLengths({
    required String title,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList =
        courseScheduleItems.where((element) => element.title == title).toList();
    if (elementList.isEmpty) {
      return [];
    } else {
      List lengthList = [];
      elementList.forEach((element) {
        if (!lengthList.contains(element.length)) {
          lengthList.add(element.length);
        }
      });

      return lengthList;
    }
  }

  List getPlaces({
    required String title,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList =
        courseScheduleItems.where((element) => element.title == title).toList();
    if (elementList.isEmpty) {
      return [];
    } else {
      List placeList = [];
      elementList.forEach((element) {
        if (!placeList.contains(element.place)) {
          placeList.add(element.place);
        }
      });
      return placeList;
    }
  }

  List getInstructors({
    required String title,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList =
        courseScheduleItems.where((element) => element.title == title).toList();
    if (elementList.isEmpty) {
      return [];
    } else {
      List instructorList = [];
      elementList.forEach((element) {
        if (!instructorList.contains(element.instructor)) {
          instructorList.add(element.instructor);
        }
      });
      return instructorList;
    }
  }
}
