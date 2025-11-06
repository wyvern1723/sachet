import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/free_classroom_data_zf.dart';
import 'package:sachet/models/free_classroom_request_data.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/time_manager.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom.dart';

/// 时间段
const List<List<int>> itemList = [
  [1, 2],
  [3, 4],
  [5, 6],
  [7, 8],
  [9, 10, 11]
];

/// 获取一天的所有空闲教室的数据（正方教务）
///
/// Return 空闲教室二维列表
///
/// e.g.
///
/// ```dart
/// [
///   ["逸夫楼-101","空","满","空","空","满"],
///   ["逸夫楼-102","空","空","空","空","满"],
///   ["逸夫楼-103","空","满","满","空","空"],
///   ["逸夫楼-104","空","满","空","满","满"]
/// ]
/// ```
Future<List<List<String>>> getFreeClassroomFullDayZF({
  required String cookie,
  required String semesterYear,
  required String semesterIndex,
  required DateTime date,
  required ZhengFangUserProvider? zhengFangUserProvider,
}) async {
  // 获取那一天的周次和星期几
  final weekCountAndWeekday = getWeekCountAndWeekdayOfDate(
    semesterStartDate: DateTime.tryParse(SettingsProvider.semesterStartDate) ??
        constSemesterStartDate,
    date: date,
  );

  final String zcd =
      calculateZcdOrJcd([weekCountAndWeekday.weekCount]).toString();
  final String xqj = [weekCountAndWeekday.weekday].join(',');

  /// 空闲教室二维列表
  ///
  /// e.g.
  ///
  /// [
  ///   ["逸夫楼-101","空","满","空","空","满"],
  ///   ["逸夫楼-102","空","空","空","空","满"],
  ///   ["逸夫楼-103","空","满","满","空","空"],
  ///   ["逸夫楼-104","空","满","空","满","满"]
  /// ]
  List<List<String>> classroomDataGrid = [];

  for (var item in itemList) {
    final String jcd = calculateZcdOrJcd(item).toString();
    final String nd = DateTime.now().millisecondsSinceEpoch.toString();
    final Map data = FreeClassroomRequestDataZF(
      xqhId: '02', // 默认校区为 "校本部"
      xnm: semesterYear,
      xqm: semesterIndex,
      cdlbId: '01', // 默认场地类别为 "教室"
      qszws: '',
      jszws: '',
      zcd: zcd,
      xqj: xqj,
      jcd: jcd,
      lh: '',
      nd: nd,
    ).toJson();

    /// 一个时间段([1, 2]/[3, 4]/[5, 6]/[7, 8]/[9, 10, 11]) 的空闲教室数据(只返回空闲的教室)
    final List<FreeClassroomDataZF> freeClassroomPerItem =
        await getFreeClassroomZF(cookie: cookie, data: data);

    for (var classroom in freeClassroomPerItem) {
      final classroomName = classroom.classroomName;
      final int index =
          classroomDataGrid.indexWhere((e) => e[0] == classroomName);

      if (index == -1) {
        // classroomDataGrid 中没有这个教室，可能是之前时间段都是 "满"，或是第一个时间段就是 "空"。
        final List<String> list = [classroomName, "满", "满", "满", "满", "满"];
        list[itemList.indexOf(item) + 1] = "空";
        classroomDataGrid.add(list);
      } else {
        // classroomDataGrid 中有这个教室，将这个教室当前时间段的状态设为 "空"。
        classroomDataGrid[index][itemList.indexOf(item) + 1] = "空";
      }
    }
  }
  // 根据每个子列表的第一个元素（教室名称）排序
  classroomDataGrid.sort((a, b) => a[0].compareTo(b[0]));
  return classroomDataGrid;
}
