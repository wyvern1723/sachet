import 'package:sachet/services/qiangzhi_jwxt/get_data/fetch_data_http/fetch_exam_time.dart';
import 'package:html/parser.dart';

/// 使用网页返回的数据生成考试时间数据
///
/// return  {semester: 2024-2025-1, data: [{序号: 1, 课程名称: 大学体育3, 考核方式: 考试, 考试时间: , 考场: , 备注: 星期一7-8节}, {序号: 2, 课程名称: 形势与政策3, 考核方式: , 考试时间: , 考场: , 备注: }...]}
Future<Map> generateExamTimeDataQZ(String semester) async {
  var result = await fetchExamTimeDataQZ(semester);

  var document = parse(encoding: '', result);
  var listLength =
      document.getElementById('dataList')?.children[0].children.length ?? 1;
  // pathElement 表示在 html DOM 里的位置，减少代码量。
  var pathElement = document.getElementById('dataList');

  // 序号	课程名称 考核方式 考试时间 考场 备注
  List dataList = [];
  if (listLength == 1) throw '没有考试数据';
  for (int i = 2; i < listLength + 1; i++) {
    Map<String, String> data = {};
    data.addAll({
      '序号':
          pathElement?.children[0].children[i - 1].children[0].innerHtml ?? '',
      '课程名称':
          pathElement?.children[0].children[i - 1].children[2].innerHtml ?? '',
      '考核方式':
          pathElement?.children[0].children[i - 1].children[3].innerHtml ?? '',
      '考试时间':
          pathElement?.children[0].children[i - 1].children[5].innerHtml ?? '',
      '考场':
          pathElement?.children[0].children[i - 1].children[6].innerHtml ?? '',
      '备注':
          pathElement?.children[0].children[i - 1].children[9].innerHtml ?? '',
    });
    dataList.add(data);
  }
  Map jsonData = {};
  jsonData.addAll({"semester": semester, "data": dataList});
  return jsonData;
}
