import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/app_folder.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/utils/transform.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

/// 获取课程名称
///
/// return 课程名称 List
List<String> getCourseList(
    {required List<List<CourseSchedule>> classScheduleData}) {
  List<String> courseTitleList = [];

  for (int i = 0; i < 35; i++) {
    List<CourseSchedule> oneSesssionCourses = classScheduleData[i];
    oneSesssionCourses.forEach((element) {
      String title = element.title ?? '';
      if (courseTitleList.contains(title) == false && title != '') {
        courseTitleList.add(title);
      }
    });
  }
  return courseTitleList;
}

/// 给课程随机分配颜色
///
/// return {'课程1': color1Hex,'课程2': color2Hex,......}
Map<String, String> randomAllocateColorToCourse({
  required List courseTitleList,
  List<Color>? palette,
}) {
  // 如果没有传入 palette, 默认为 materialColorsShade400（Material Color Scheme Shade 400）
  palette ??= materialColorsShade400;

  Map<String, String> courseColorMap = {};

  // 打乱 palette List
  palette.shuffle();

  // 如果 课程名称 List 的长度超出了 预设配色 List 的长度
  if (courseTitleList.length > palette.length) {
    int newValue = 0;
    for (int i = 0; i < courseTitleList.length; i++) {
      if (newValue > palette.length - 1) {
        // 如果 newValue 超出了 length 就给 newValue 减去 colors.length, 重新从 0 开始
        newValue = newValue - palette.length;
      }
      courseColorMap.addAll(
        {
          courseTitleList[i]: colorToHex(
            palette[newValue],
            includeHashSign: true,
            toUpperCase: true,
          )
        },
      );
      newValue++;
    }
  } else {
    for (int i = 0; i < courseTitleList.length; i++) {
      courseColorMap.addAll({
        courseTitleList[i]: colorToHex(
          palette[i],
          includeHashSign: true,
          toUpperCase: true,
        )
      });
    }
  }

  return courseColorMap;
}

/// 把随机分配完颜色的 课程-颜色 文件储存到 AppSupportDir
///
/// return 文件保存的路径
Future<String> storeRandomizationCourseColorFile({
  required Map courseColorData,
  required String semester,
}) async {
  String fileName =
      "course_color_${semester}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json";

  await CachedDataStorage().writeFileToAppSupportDir(
    fileName: fileName,
    folder: AppFolder.courseColor.name,
    value: formatJsonEncode(courseColorData),
  );

  var localPath = await CachedDataStorage().getPath();
  var filePath = path.join(localPath, AppFolder.courseColor.name, fileName);
  return filePath;
}
