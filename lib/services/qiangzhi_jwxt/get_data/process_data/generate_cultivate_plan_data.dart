import 'package:sachet/services/qiangzhi_jwxt/get_data/fetch_data_http/fetch_cultivate_plan.dart';

import 'package:html/parser.dart';

/// 使用网页返回的数据生成培养方案数据
Future<List?> generateCultivatePlanDataQZ() async {
  var result = await fetchCultivatePlanDataQZ();
  var document = parse(encoding: '', result);

  // pathElement 表示在 html DOM 里的位置，减少代码量。
  var pathElement = document.getElementById('dataList')?.children[0];
  var listLength = pathElement?.children.length ?? 0;

  List<Map> listData = [];
  for (int i = 2; i < listLength + 1; i++) {
    Map<String, String> data = {};
    data.addAll({
      '序号': pathElement?.children[i - 1].children[0].innerHtml ?? '',
      '开课学期': pathElement?.children[i - 1].children[1].innerHtml ?? '',
      '课程名称': pathElement?.children[i - 1].children[2].innerHtml ?? '',
      '课程类别': pathElement?.children[i - 1].children[4].innerHtml ?? '',
      '总学时': pathElement?.children[i - 1].children[5].innerHtml ?? '',
      '学分': pathElement?.children[i - 1].children[6].innerHtml ?? '',
      '考核方式': pathElement?.children[i - 1].children[7].innerHtml ?? '',
    });
    listData.add(data);
  }
  return listData;
}
