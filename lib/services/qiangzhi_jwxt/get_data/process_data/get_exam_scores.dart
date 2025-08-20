// 在成绩查询那一页上使用的数据的 model 都在这里

import 'package:sachet/services/qiangzhi_jwxt/get_data/fetch_data_http/fetch_exam_scores.dart';
import 'package:html/parser.dart';

/// 获取考试成绩数据
Future<List> getExamScoresGradeDataQZ(String semester) async {
  var result = await fetchExamScoresGradeDataQZ(semester);

  var document = parse(encoding: '', result);
  // pathElement 表示在 html DOM 里的位置，减少代码量。
  var pathElement = document.getElementById('dataList')?.children[0];
  var listLength = pathElement?.children.length ?? 10;

  /// 是否未完成评教
  bool isWeiPingJiao;

  isWeiPingJiao = result.contains('评教未完成');

  // print('是否未评教:$isWeiPingJiao');
  // 学期末前都要进行评教，如果没有评教，就不能查看课表（在网页上会有一个弹窗）
  // 为防止误判，需要满足 未完成评教 和 listLength = 1 才显示未完成评教。
  // listLength = 1 即代表返回的数据只有表头（”序号“、“课程名称”、“开课学期”……），没有实际课程考试成绩数据。
  // 但是当考试成绩一门都没出的时候，listLength 也是1。
  if (isWeiPingJiao && listLength == 1) {
    throw '评教未完成，不能查询成绩。请先完成评教。';
  } else {
    // 0    1        2        3     4     5      6        7        8
    // 序号	开课学期	课程名称	成绩	学分	总学时	考核方式	课程属性	课程性质
    List dataAll = [];
    for (int i = 2; i < listLength + 1; i++) {
      Map<String, String> data = {};
      data.addAll({
        '序号': pathElement?.children[i - 1].children[0].innerHtml ?? '',
        '开课学期': pathElement?.children[i - 1].children[1].innerHtml ?? '',
        '课程名称': pathElement?.children[i - 1].children[2].innerHtml ?? '',
        '总成绩': pathElement?.children[i - 1].children[3].children[0].innerHtml ??
            '',
        '学分': pathElement?.children[i - 1].children[4].innerHtml ?? '',
        '总学时': pathElement?.children[i - 1].children[5].innerHtml ?? '',
        '考核方式': pathElement?.children[i - 1].children[6].innerHtml ?? '',
        '课程属性': pathElement?.children[i - 1].children[7].innerHtml ?? '',
        '课程性质': pathElement?.children[i - 1].children[8].innerHtml ?? '',
        'detailsUrl': pathElement
                ?.children[i - 1].children[3].children[0].attributes["href"]
                ?.split("'")[1] ??
            '',
      });
      dataAll.add(data);
    }
    return dataAll;
  }
}

/// 获取成绩查询的可选择学期
Future getGradeSemesterData() async {
  var result = await fetchGradeSemesterDataQZ();

  var document = parse(encoding: '', result);
  var pathElement = document.getElementById('kksj');
  var listLength = pathElement?.children.length ?? 10;

  Map<String, String> data = {};
  for (int i = 1; i < listLength + 1; i++) {
    var child = pathElement?.children[i - 1];
    data.addAll({
      child?.innerHtml ?? '': child?.attributes['value'] ?? '',
    });
  }

  return data;
}

/// 获取 GPA 和排名数据
Future getGPAandRankData(String semester) async {
  var result = await fetchGPAandRankDataQZ(semester);

  var document = parse(encoding: '', result);
  var pathElement = document.getElementById('dataList')?.children[0];
  var listLength = pathElement?.children.length ?? 1;

  Map<String, String> data = {};
  if (listLength > 1) {
    data.addAll({
      '平均绩点': pathElement?.children[1].children[0].innerHtml ?? '',
      '平均成绩': pathElement?.children[1].children[1].innerHtml ?? '',
      '绩点班级排名': pathElement?.children[1].children[2].innerHtml ?? '',
      '绩点专业排名': pathElement?.children[1].children[3].innerHtml ?? '',
    });
  } else {
    data.addAll({
      '平均绩点': '--',
      '平均成绩': '--',
      '绩点班级排名': '--',
      '绩点专业排名': '--',
    });
  }

  return data;
}

/// 获取平时分数据
///
/// return ['平时成绩','平时成绩比例']
Future<List<String>> getGeneralPerformanceMarksData(String detailsUrl) async {
  var result = await fetchGeneralPerformanceMarksDataQZ(detailsUrl);

  var document = parse(encoding: '', result);
  var pathElement =
      document.getElementById('dataList')?.children[0].children[1];
  // var listLength = pathElement?.children.length ?? 10;
  var data1 = pathElement?.children[1].innerHtml;
  var data2 = pathElement?.children[2].innerHtml;

  return [data1 ?? '无', data2 ?? '无'];
}
