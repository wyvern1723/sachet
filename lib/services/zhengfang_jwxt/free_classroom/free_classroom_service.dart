import 'dart:math';

import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/providers/free_classroom_page_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/auto_login_retry.dart';
import 'package:sachet/utils/time_manager.dart';

import 'models/free_classroom_filter_options.dart';
import 'models/free_classroom_data_response_zf.dart';
import 'models/free_classroom_request_data_zf.dart';
import 'fetch_free_classroom.dart';
import 'free_classroom_filter_options/fetch_free_classroom_filter_options.dart';
import 'free_classroom_filter_options/parse_free_classroom_filter_options.dart';
import 'teaching_buildings/fetch_teaching_buildings.dart';

class FreeClassroomService {
  const FreeClassroomService();

  /// 获取空教室查询页面中多个下拉选择器的数据
  ///
  /// 返回三个筛选项: 学年学期、教学楼、场地类别 的选项列表 Map<label: value> 和当前选中值。
  Future<FreeClassroomFilterOptionsZF> getFreeClassroomFilterOptions({
    required String cookie,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final html =
            await fetchFreeClassroomFilterOptionsZF(cookie: activeCookie);
        return parseFreeClassroomFilterOptionsZF(html);
      },
    );
  }

  /// 获取空闲教室可选的教学楼(不包括 "全部":"" )
  ///
  /// return e.g.
  ///
  /// {"北山画室": "209", "北山阶梯": "206", "材料大楼": "907", "测试中心": "902", "第二教学楼": "109"}
  Future<Map<String, String>> getTeachingBuildings({
    required String cookie,

    /// xnm 学年名，如 '2025'=> 指 2025-2026 学年
    required String semesterYear,

    /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期
    required String semesterIndex,
  }) async {
    final List result = await fetchTeachingBuildingsZF(
      cookie: cookie,
      semesterYear: semesterYear,
      semesterIndex: semesterIndex,
    );
    Map<String, String> teachingBuildingMap = {};
    for (final e in result) {
      String teachingBuildingName = e['JXLMC'];
      String teachingBuildingValue = e['JXLDM'];
      teachingBuildingMap.addAll({teachingBuildingName: teachingBuildingValue});
    }
    return teachingBuildingMap;
  }

  Future<List<FreeClassroomDataResponseZF>> getFreeClassroom({
    required String cookie,
    required Map data,
  }) async {
    final List result = await fetchFreeClassroomZF(cookie: cookie, data: data);
    List<FreeClassroomDataResponseZF> dataList = [];
    for (final element in result) {
      FreeClassroomDataResponseZF classroomData =
          FreeClassroomDataResponseZF.fromJson(element);
      dataList.add(classroomData);
    }
    return dataList;
  }

  /// 获取今日或明日的空闲教室数据（正方教务）
  ///
  /// Return （空闲教室二维列表, 听力教室 Set）
  ///
  /// List<List<String>> 空闲教室二维列表 e.g.
  ///
  /// itemList = [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10, 11]];
  ///
  /// ```dart
  /// [
  ///   ["逸夫楼-101","空","满","空","空","满"],
  ///   ["逸夫楼-102","空","空","空","空","满"],
  ///   ["逸夫楼-103","空","满","满","空","空"],
  ///   ["逸夫楼-104","空","满","空","满","满"]
  /// ]
  /// ```
  ///
  /// itemList = [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10],[11]];
  ///
  /// ```dart
  /// [
  ///   ["逸夫楼-101","空","满","空","空","满","满"],
  ///   ["逸夫楼-102","空","空","空","空","满","满"],
  ///   ["逸夫楼-103","空","满","满","空","空","空"],
  ///   ["逸夫楼-104","空","满","空","满","满","满"]
  /// ]
  /// ```
  Future<
      ({
        List<List<String>> classroomDataGrid,
        Set<String> listeningClassrooms
      })> getFreeClassroomTodayAndTomorrow({
    required String cookie,
    required String semesterYear,
    required String semesterIndex,
    required Day day,

    /// 把一天分成的时间段, 例如
    /// [
    ///   [1, 2],
    ///   [3, 4],
    ///   [5, 6],
    ///   [7, 8],
    ///   [9, 10, 11]
    /// ];
    required List itemList,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    final firstDate = getDateFromWeekCountAndWeekday(
      semesterStartDate:
          DateTime.tryParse(SettingsProvider.semesterStartDate) ??
              constSemesterStartDate,
      weekCount: 1,
      weekday: 1,
    );
    final lastDate = getDateFromWeekCountAndWeekday(
      semesterStartDate:
          DateTime.tryParse(SettingsProvider.semesterStartDate) ??
              constSemesterStartDate,
      weekCount: 20,
      weekday: 7,
    );
    if (DateTime.now()
        .add(Duration(days: day == Day.today ? 0 : 1))
        .isBefore(firstDate)) {
      throw '学期未开始';
    }
    if (DateTime.now()
        .add(Duration(days: day == Day.today ? 0 : 1))
        .isAfter(lastDate)) {
      throw '学期已结束';
    }

    // 获取今天/明天的周次和星期几
    final weekCountAndWeekday = getWeekCountAndWeekdayOfDate(
      semesterStartDate:
          DateTime.tryParse(SettingsProvider.semesterStartDate) ??
              constSemesterStartDate,
      date: DateTime.now().add(Duration(days: day == Day.today ? 0 : 1)),
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

    /// 听力教室（语音教室）
    Set<String> listeningClassrooms = {};

    for (final item in itemList) {
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
      final List<FreeClassroomDataResponseZF> freeClassroomPerItem =
          await getFreeClassroom(cookie: cookie, data: data);

      for (final classroom in freeClassroomPerItem) {
        final classroomName = classroom.classroomName;

        if (classroom.placeSubType == '语音教室') {
          listeningClassrooms.add(classroomName);
        }

        final int index =
            classroomDataGrid.indexWhere((e) => e[0] == classroomName);

        if (index == -1) {
          // classroomDataGrid 中没有这个教室，可能是之前时间段都是 "满"，或是第一个时间段就是 "空"。
          final List<String> list = [
            classroomName,
            ...List.filled(itemList.length, "满")
          ];
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

    return (
      classroomDataGrid: classroomDataGrid,
      listeningClassrooms: listeningClassrooms
    );
  }

  /// 获取一天的所有空闲教室的数据（正方教务）
  ///
  /// Return （空闲教室二维列表, 听力教室 Set）
  ///
  /// List<List<String>> 空闲教室二维列表 e.g.
  ///
  /// itemList = [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10, 11]];
  ///
  /// ```dart
  /// [
  ///   ["逸夫楼-101","空","满","空","空","满"],
  ///   ["逸夫楼-102","空","空","空","空","满"],
  ///   ["逸夫楼-103","空","满","满","空","空"],
  ///   ["逸夫楼-104","空","满","空","满","满"]
  /// ]
  /// ```
  ///
  /// itemList = [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10],[11]];
  ///
  /// ```dart
  /// [
  ///   ["逸夫楼-101","空","满","空","空","满","满"],
  ///   ["逸夫楼-102","空","空","空","空","满","满"],
  ///   ["逸夫楼-103","空","满","满","空","空","空"],
  ///   ["逸夫楼-104","空","满","空","满","满","满"]
  /// ]
  /// ```
  Future<
      ({
        List<List<String>> classroomDataGrid,
        Set<String> listeningClassrooms
      })> getFreeClassroomFullDay({
    required String cookie,
    required String semesterYear,
    required String semesterIndex,
    required DateTime date,

    /// 把一天分成的时间段, 例如
    /// [
    ///   [1, 2],
    ///   [3, 4],
    ///   [5, 6],
    ///   [7, 8],
    ///   [9, 10, 11]
    /// ];
    required List itemList,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    // 获取那一天的周次和星期几
    final weekCountAndWeekday = getWeekCountAndWeekdayOfDate(
      semesterStartDate:
          DateTime.tryParse(SettingsProvider.semesterStartDate) ??
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

    /// 听力教室（语音教室）
    Set<String> listeningClassrooms = {};

    for (final item in itemList) {
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
      final List<FreeClassroomDataResponseZF> freeClassroomPerItem =
          await getFreeClassroom(cookie: cookie, data: data);

      for (final classroom in freeClassroomPerItem) {
        final classroomName = classroom.classroomName;

        if (classroom.placeSubType == '语音教室') {
          listeningClassrooms.add(classroomName);
        }

        final int index =
            classroomDataGrid.indexWhere((e) => e[0] == classroomName);

        if (index == -1) {
          // classroomDataGrid 中没有这个教室，可能是之前时间段都是 "满"，或是第一个时间段就是 "空"。
          final List<String> list = [
            classroomName,
            ...List.filled(itemList.length, "满")
          ];
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

    return (
      classroomDataGrid: classroomDataGrid,
      listeningClassrooms: listeningClassrooms
    );
  }
}

///
/// 计算zcd或jcd值
///
/// 示例:
///
/// ```dart
/// // 计算选择了第1、3、5周的zcd值
/// double zcd = calculateZcdOrJcd([1, 3, 5]);
/// print(zcd); // 输出 21 (1 + 4 + 16)
/// ```
///
/// [selectedValues] : 选中的值列表（如[1, 3, 5]表示选择了第1、3、5项）
///
/// 根据 `https://jw.xtu.edu.cn/jwglxt/js/comp/jwglxt/pkgl/cdjy/kxcdlb.js`
///
/// 处理周次
///
/// ```js
/// var zcd = 0;
/// $("#selectTR_ZC .selectTH.ui-selected").each(function(i, dom) {
///     zcd += Math.pow(2, $(dom).attr("value") - 1);
/// });
/// map["zcd"] = zcd;
/// ```
///
/// 处理节次:
///
/// ```js
/// var jcd = 0;
/// $("#selectTR_JC .selectTH.ui-selected").each(function(i, dom) {
///     jcd += Math.pow(2, $(dom).attr("value") - 1);
/// });
/// map["jcd"] = jcd;
/// ```
int calculateZcdOrJcd(List<int> selectedValues) {
  int result = 0;

  for (int value in selectedValues) {
    int powerValue = pow(2, value - 1).toInt();
    result += powerValue;
  }

  // or:
  /*
  for (int value in selectedValues) {
    // 使用位运算 1 << (value - 1) 等同于 Math.pow(2, value - 1)
    result += 1 << (value - 1);
  }
  */

  return result;
}
