import 'package:sachet/models/free_classroom_filter_options.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/fetch_data/fetch_free_classroom_filter_options.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/parse_data/parse_free_classroom_filter_options.dart';

/// 获取空教室查询页面中多个下拉选择器的数据
///
/// 返回三个筛选项: 学年学期、教学楼、场地类别 的选项列表 Map<label: value> 和当前选中值。

Future<FreeClassroomFilterOptionsZF> getFreeClassroomFilterOptionsZF(
    {required String cookie}) async {
  final html = await fetchFreeClassroomFilterOptionsZF(cookie: cookie);

  return parseFreeClassroomFilterOptionsZF(html);
}
