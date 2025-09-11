import 'dart:math';

import 'package:sachet/models/free_classroom_data_zf.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_free_classroom.dart';

Future<List<FreeClassroomDataZF>> getFreeClassroomZF({
  required String cookie,
  required Map data,
}) async {
  final List result = await fetchFreeClassroomZF(cookie: cookie, data: data);
  List<FreeClassroomDataZF> dataList = [];
  for (var element in result) {
    FreeClassroomDataZF classroomData = FreeClassroomDataZF.fromJson(element);
    dataList.add(classroomData);
  }
  return dataList;
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
