// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:sachet/models/course_schedule.dart';

class CourseInfoHelper {
  static List getWeeksOfCourse({
    required String title,
    bool? isExperimentCourse,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList = courseScheduleItems
        .where(
          (element) =>
              element.title == title &&
              // 等价写法
              // ((isExperimentCourse == null || isExperimentCourse == false)
              //     ? element.isExperimentCourse != true
              //     : element.isExperimentCourse == true),
              (element.isExperimentCourse ?? false) ==
                  (isExperimentCourse ?? false),
        )
        .toList();
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

  static List<int> getLengths({
    required String title,
    bool? isExperimentCourse,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList = courseScheduleItems
        .where((element) =>
            element.title == title &&
            (element.isExperimentCourse ?? false) ==
                (isExperimentCourse ?? false))
        .toList();
    if (elementList.isEmpty) {
      return [];
    } else {
      List<int> lengthList = [];
      elementList.forEach((element) {
        final int? length = element.length;
        if (!lengthList.contains(length)) {
          if (length != null) {
            lengthList.add(length);
          }
        }
      });

      return lengthList;
    }
  }

  static List getPlaces({
    required String title,
    bool? isExperimentCourse,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList = courseScheduleItems
        .where((element) =>
            element.title == title &&
            (element.isExperimentCourse ?? false) ==
                (isExperimentCourse ?? false))
        .toList();
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

  static List getInstructors({
    required String title,
    bool? isExperimentCourse,
    required List<CourseSchedule> courseScheduleItems,
  }) {
    List<CourseSchedule> elementList = courseScheduleItems
        .where((element) =>
            element.title == title &&
            (element.isExperimentCourse ?? false) ==
                (isExperimentCourse ?? false))
        .toList();
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
