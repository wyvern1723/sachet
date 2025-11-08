import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/get_exam_scores.dart';

/// 用于 [GradePageQZ] 强智教务系统的成绩查询页面的 Provider
class GradePageQZProvider extends ChangeNotifier {
  bool _isShowDetails = false; // 是否显示成绩的详细信息

  bool get isShowDetails => _isShowDetails;

  void changeIsShowDetails() {
    _isShowDetails = !isShowDetails;
    notifyListeners();
  }

  String _semester = '';

  String get semester => _semester;

  var data;

  Future<List> getExamScoresSimpleData() async {
    data = await getExamScoresGradeDataQZ(_semester);
    return data;
  }

  Future<List> getExamScoresDetailsData() async {
    data = await getExamScoresGradeDataQZ(_semester);
    await appendMoreDataToSimple(data);
    return data;
  }

  Future<dynamic> getGPAData() async {
    var GPAdata = await getGPAandRankData(_semester);
    return GPAdata;
  }

  /// 给一般的数据添加平时分、平时分占比
  Future appendMoreDataToSimple(List passdata) async {
    int length = passdata.length;

    // fetchDataDuration（获取数据的延迟，发现请求太快可能会发生错误，所以加入了一个保险的延迟）
    // TODO: 研究最佳延迟时间。（现在是1s,可能太长）
    const fetchDataDuration = Duration(milliseconds: 500);

    for (int i = 0; i < length; i++) {
      String url = passdata[i]['detailsUrl'];
      List<String> generalPerformanceData =
          await getGeneralPerformanceMarksData(url);

      /// 平时分分数
      dynamic generalPerformanceMark = int.tryParse(generalPerformanceData[0]);

      // 如果不是 int 类型（分数可能为 double，如 80.5)
      generalPerformanceMark ??= double.tryParse(generalPerformanceData[0]);
      // 如果也不是 double 类型，如「优」。
      generalPerformanceMark ??= generalPerformanceData[0];

      if (generalPerformanceMark != null) {
        String generalPerformanceMarkString = generalPerformanceMark.toString();

        data[i].addAll({
          '平时成绩分数': generalPerformanceMarkString,
        });
      }

      /// 平时分占比(只是'%'前的数字，eg. 60% --> 60)
      // 先尝试是不是 int
      dynamic generalPerformanceMarkProportion =
          int.tryParse(generalPerformanceData[1].split('%')[0]);

      // 不是 int，尝试是不是 double
      generalPerformanceMarkProportion ??=
          double.tryParse(generalPerformanceData[1].split('%')[0]);

      // 不是 double 直接赋予获得的值
      generalPerformanceMarkProportion ??= generalPerformanceData[1];

      if (generalPerformanceMarkProportion != null) {
        String generalPerformanceMarkProportionString =
            generalPerformanceMarkProportion.toString();

        data[i].addAll({
          '平时成绩比例': generalPerformanceMarkProportionString,
        });
      }
      if (generalPerformanceMark != null &&
          generalPerformanceMark != '' &&
          generalPerformanceMarkProportion != null &&
          generalPerformanceMarkProportion != '') {
        data[i].addAll({
          '平时成绩': '$generalPerformanceMark($generalPerformanceMarkProportion%)',
        });
      } else if (generalPerformanceMark != null &&
          generalPerformanceMark != '') {
        data[i].addAll({
          '平时成绩': '$generalPerformanceMark(--%)',
        });
      } else if (generalPerformanceMarkProportion != null &&
          generalPerformanceMarkProportion != '') {
        data[i].addAll({
          '平时成绩': '--($generalPerformanceMarkProportion%)',
        });
      } else {
        data[i].addAll({
          '平时成绩': '--',
        });
      }
      // print('-------------------------------');
      // print('平时成绩: $generalPerformanceMark($generalPerformanceMarkProportion)');

      // 下面在计算卷面成绩。
      // 为什么不直接用 (总成绩-平时分*平时分占比)/期末成绩占比 来算卷面分(期末成绩)呢？
      // 因为计算最终成绩是四舍五入的，平时分乘占比 + 卷面分乘占比 得到的结果几乎都是有小数的，最终成绩直接舍弃了一部分精度
      // 根据 四舍五入后的总成绩 再倒着计算回去 得到的值也是有小数的，这时再直接四舍五入得到的不一定是原始的(正确的)值。
      // 所以会有一个可能值(probableValues)列表，代表你的卷面分有这几种可能，用 平时分乘占比 + 卷面分乘占比 这个公式算出的四舍五入后的总成绩都等于给出的总成绩。
      // 当然这是一个非常蠢的方法，从 0 到 100 挨个试，很暴力。应该有更高效的方法的，但我不懂算法，对于现代的 CPU，这点计算差距用户也注意不到。所以我就放弃脑力体操了。
      double? totalScore = double.tryParse(data[i]['总成绩']);
      // 需要 平时分、平时分占比、总成绩，才能计算卷面成绩。
      if (generalPerformanceMark != null &&
          generalPerformanceMarkProportion != null &&
          generalPerformanceMark is num &&
          generalPerformanceMarkProportion is num &&
          totalScore != null) {
        /// 可能的值
        List probableValues = [];
        for (int probableValue = 0; probableValue < 100; probableValue++) {
          if ((generalPerformanceMark * generalPerformanceMarkProportion / 100 +
                      probableValue *
                          (1 - generalPerformanceMarkProportion / 100))
                  .round() ==
              totalScore) {
            probableValues.add(probableValue);
          }
        }
        String probableValuesString = probableValues
            .toString()
            .replaceFirst(RegExp(r'\['), '')
            .replaceAll(RegExp(r'\]'), '')
            .replaceAll(RegExp(r', '), '/');
        num finalExamProportion = 100 - generalPerformanceMarkProportion;
        String finalExamProportionString = finalExamProportion.toString();
        data[i].addAll({
          '期末成绩分数': probableValuesString,
          '期末成绩比例': finalExamProportionString,
        });
        data[i].addAll({
          '期末成绩': '$probableValuesString($finalExamProportionString%)',
        });
        // print('期末成绩(卷面成绩)$probableValuesString($finalExamProportionString%)');
      } else {
        // 其他情况，平时分、平时分占比、总成绩 任意一个值没有时，添加 -- 占位，表示没有有效数据。
        data[i].addAll({
          '期末成绩': '--',
        });
        // print('期末成绩(卷面成绩)为 --');
      }
      // print('appendMoreDataToSimple finished ${i + 1}/$length');

      // 延迟 fetchDataDuration（获取数据的延迟，发现请求太快可能会发生错误，所以加入了一个保险的延迟）
      // TODO: 研究最佳延迟时间。（现在是0.5s,可能太长）
      Future.delayed(fetchDataDuration);
    }
  }

  void changeSemester(String value) {
    _semester = value;
    notifyListeners();
  }

  void changeData(List value) {
    data = value;
    notifyListeners();
  }
}
