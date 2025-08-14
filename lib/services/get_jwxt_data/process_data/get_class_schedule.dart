import 'dart:io';

import 'package:sachet/models/app_folder.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/models/course_schedule_raw_data.dart';
import 'package:sachet/services/get_jwxt_data/fetch_data_http/fetch_class_schedule.dart';
import 'package:sachet/services/get_jwxt_data/process_data/generate_course_color.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/utils/transform.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

/// 获取课程表文件（是一个庞大复杂的函数）
///
/// return [生成的课程表文件路径，随机分配颜色的课程-颜色文件路径]
Future<List<String>> getClassScheduleData(String semester) async {
  List<List<CourseScheduleRawData>> courseses = [];

  // fetchDataDuration（获取数据的延迟，发现请求太快可能会发生错误，所以加入了一个保险的延迟）
  // TODO: 研究最佳延迟时间。（现在是0.5s,可能太长）
  const fetchDataDuration = Duration(milliseconds: 500);

  for (int i = 1; i < 21; i++) {
    /// 获取第 i 周数据
    var weekiData = await fetchClassSchedule(
      weekCount: i,
      semester: semester,
    );

    var document = parse(encoding: '', weekiData);

    // 获取长度（其实多余，都是 35）
    var listLength = document.getElementsByClassName('kbcontent').length;
    // pathElement 表示在 html DOM 里的位置，减少代码量。
    var pathElement = document.getElementsByClassName('kbcontent');

    List<CourseScheduleRawData> courses = [];

    for (int i = 0; i < listLength; i++) {
      String? courseTitle;
      String? courseInstructor;
      String? coursePlace;
      int? courseLength;

      // 课程信息例子
      // length >= 10
      // 高等数学I, 宋教授, 2-19周, 兴教楼C209, 上课节次：4节
      // length == 8
      // 高等数学I, 宋教授, 2-19周, 兴教楼C209
      // length == 6
      // 高等数学I, 宋教授, 2-19周
      if (pathElement[i].nodes.length >= 10) {
        String? shangkejieci = pathElement[i].nodes[8].text;
        int? courseLengthInt;

        if (shangkejieci != null) {
          courseLengthInt =
              int.tryParse(shangkejieci.split('：')[1].split('节')[0]);
        }
        courseTitle = pathElement[i].nodes[0].text;
        courseInstructor = pathElement[i].nodes[2].text;
        coursePlace = pathElement[i].nodes[6].text;
        courseLength = courseLengthInt ?? 2;
      } else if (pathElement[i].nodes.length == 8) {
        courseTitle = pathElement[i].nodes[0].text;
        courseInstructor = pathElement[i].nodes[2].text;
        coursePlace = pathElement[i].nodes[6].text;
      } else if (pathElement[i].nodes.length == 6) {
        courseTitle = pathElement[i].nodes[0].text;
        courseInstructor = pathElement[i].nodes[2].text;
      } else {}
      CourseScheduleRawData newCourse = CourseScheduleRawData(
        courseTitle: courseTitle ?? '',
        courseInstructor: courseInstructor ?? '',
        coursePlace: coursePlace ?? '',
        courseLength: courseLength ?? 2,
      );
      courses.add(newCourse);
    }
    courseses.add(courses);

    // 延迟 fetchDataDuration。（获取数据的延迟，发现请求太快可能会发生错误，所以加入了一个保险的延迟）
    // TODO: 研究最佳延迟时间。（现在是0.5s,可能太长）
    Future.delayed(fetchDataDuration);
  }

// 获取的 courseses 是课程表信息的原始文件
// 以 周次 为大的分类，一个大 List 有 20 个 children（20周），每个 child 都是一个小 List, 又含有 35 个 children (35 个 item(时间段))
// 共有 35 x 20 = 700 项，文件太大，数据有很多重复。

// 所以经过下面 getAllScheduleItemCourse() 函数的处理，「压缩(整合)」了文件，
// 以 item (时间段) 为大的分类，一个大 List 有 35 个 children（35 个 item(时间段)），每个 child 都是一个小 List, 又含有这个 item 内的课程信息(children 数>1)
// (例如 周一上午 01-02 节，前10周是一门课，上完后在这个时间段又开始另一门课,那这个 小 List 就有 2 个 children) <-- 少数情况(还有极少数情况 children 的数量 =3)
// (如果 周一上午 01-02 节，前10周是一门课，上完后在这个时间段没有别的课了,那这个 小 List 就只有 1 个 children) <-- 大多数情况
// 总项数 35 x (1~2) = 35 ~ 70 项，可见，极大的压缩了文件项数，让文件信息更集中，更容易处理数据。
// TODO: 中间数据处理有些复杂，可以简化一下（因为这两个部分是分开写的，本来没考虑一步到位。）
  List<List<CourseSchedule>> classScheduleData =
      getAllScheduleItemCourse(courseses);
  // 把课程表文件储存到 AppSupportDir
  String outputClassScheduleFilePath =
      await storeClassScheduleFile(classScheduleData, semester);

  // 获取课程名称 List
  List courseTitleList = getCourseList(classScheduleData: classScheduleData);

  // 把课程名称 List 交给 randomAllocateColorToCourse()，让它随机分配预设的几种颜色
  Map courseColorData =
      randomAllocateColorToCourse(courseTitleList: courseTitleList);

  // 把随机分配后得到的{课程1:颜色1,课程2:颜色2,.......}文件储存到 AppSupportDir
  String outputCourseColorpath = await storeRandomizationCourseColorFile(
    courseColorData: courseColorData,
    semester: semester,
  );

  return [outputClassScheduleFilePath, outputCourseColorpath];
}

/// 获取一个 ScheduleItem 内所有周次的课程信息。
///
/// 一个 ScheduleItem：(1 2)节/(3 4)节/ 5 6)节/(7 8)节/(9 10 11) 节…… 共 5(ScheduleItem/天) x 7(天) = 35 ScheduleItems。
List<CourseSchedule> getOneScheduleItemCourses({
  required List<CourseScheduleRawData> courseScheduleData,
  required int originItem,
  required int newItem,
}) {
  // 一个 ScheduleItem 内出现的课程 列表
  List<CourseSchedule> scheduleItemCourseList = [];
  // 每个 List 里 课程信息 用 Map
  for (int weekCount = 1; weekCount < 21; weekCount++) {
    String? title = courseScheduleData[weekCount - 1].courseTitle;
    String? instructor = courseScheduleData[weekCount - 1].courseInstructor;
    String? place = courseScheduleData[weekCount - 1].coursePlace;
    int? length = courseScheduleData[weekCount - 1].courseLength;

    // 如果有课程
    if (title != null && title != '') {
      int index = scheduleItemCourseList.indexWhere((element) =>
          element.item == newItem &&
          element.title == title &&
          element.instructor == instructor &&
          element.place == place &&
          element.length == length);
      List weeks = [];
      if (index != -1) {
        weeks = scheduleItemCourseList[index].weeks ?? [];
        scheduleItemCourseList.removeAt(index);
      }
      weeks.add(weekCount);
      CourseSchedule courseSchedule = CourseSchedule(
        item: newItem,
        title: title,
        instructor: instructor,
        place: place,
        length: length,
        weeks: weeks,
      );
      scheduleItemCourseList.add(courseSchedule);
    }
  }

  if (scheduleItemCourseList.isEmpty) {
    CourseSchedule emptyCourseSchedule = CourseSchedule(
      item: newItem,
      title: "",
      instructor: "",
      place: "",
      length: null,
      weeks: [],
    );
    scheduleItemCourseList = [emptyCourseSchedule];
  }
  return scheduleItemCourseList;
}

/// 获取所有的 ScheduleItem 含有的课程信息（并重排）
///
/// /*
/// 原来从网页获取的数据顺序：
///       Mon Tue Wed Thu Fri Sat Sun
/// 12      0   1   2   3   4   5   6
/// 34      7   8   9  10  11  12  13
/// 56     14  15  16  17  18  19  20
/// 78     21  22  23  24  25  26  27
/// 91011  28  29  30  31  32  33  34
///
/// o - ((o % 5) * 5 )
///
/// 重排后数据顺序：
///       Mon Tue Wed Thu Fri Sat Sun
/// 12      0   5  10  15  20  25  30
/// 34      1   6  11  16  21  26  31
/// 56      2   7  12  17  22  27  32
/// 78      3   8  13  18  23  28  33
/// 91011   4   9  14  19  24  29  34
/// */
///
/// return allScheduleItemCoursesData
List<List<CourseSchedule>> getAllScheduleItemCourse(
  List<List<CourseScheduleRawData>> classScheduleData,
) {
  List<List<CourseSchedule>> allScheduleItemCoursesData = [];
  for (int newItem in List.generate(35, (i) => i)) {
    int originItem = getReoderIndex(newItem);
    // 一个 scheduleItem 段 在所有周次的 课程信息 List
    List<CourseScheduleRawData> scheduleItemRawDataInAllWeeks = [];
    for (int weekCount = 1; weekCount < 21; weekCount++) {
      CourseScheduleRawData courseScheduleRawData =
          classScheduleData[weekCount - 1][originItem];
      scheduleItemRawDataInAllWeeks.add(courseScheduleRawData);
    }
    List<CourseSchedule> oneSessionCoursesData = getOneScheduleItemCourses(
        courseScheduleData: scheduleItemRawDataInAllWeeks,
        originItem: originItem,
        newItem: newItem);
    allScheduleItemCoursesData.add(oneSessionCoursesData);
  }

  return allScheduleItemCoursesData;
}

/// 获得重排顺序的 index
///
/// 原来从网页获取的数据顺序：
///       Mon Tue Wed Thu Fri Sat Sun
/// 12      0   1   2   3   4   5   6
/// 34      7   8   9  10  11  12  13
/// 56     14  15  16  17  18  19  20
/// 78     21  22  23  24  25  26  27
/// 91011  28  29  30  31  32  33  34
///
/// 重排后数据顺序：
///       Mon Tue Wed Thu Fri Sat Sun
/// 12      0   5  10  15  20  25  30
/// 34      1   6  11  16  21  26  31
/// 56      2   7  12  17  22  27  32
/// 78      3   8  13  18  23  28  33
/// 91011   4   9  14  19  24  29  34
/// */
int getReoderIndex(int o) {
  int result = (o % 5) * 7 + (o ~/ 5);
  return result;
}

/// 把课程表文件储存到 AppSupportDir
///
/// return 储存课程表文件的路径
Future<String> storeClassScheduleFile(
    List allSessionsCoursesData, String semester) async {
  String fileName =
      "class_schedule_${semester}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json";

  await CachedDataStorage().writeFileToAppSupportDir(
    fileName: fileName,
    folder: AppFolder.classSchedule.name,
    value: formatJsonEncode(allSessionsCoursesData),
  );

  var localPath = await CachedDataStorage().getPath();
  var filePath =
      '$localPath${Platform.pathSeparator}${AppFolder.classSchedule.name}${Platform.pathSeparator}$fileName';
  return filePath;
}
