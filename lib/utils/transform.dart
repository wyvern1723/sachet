// 变换

import 'dart:convert';

/// 【0,1,2...】 => 【星期一、星期二、星期三……】
Map<int, String> weekDayToXingQiJi = {
  0: '星期一',
  1: '星期二',
  2: '星期三',
  3: '星期四',
  4: '星期五',
  5: '星期六',
  6: '星期日',
};

/// 【0,1,2...】 => 【周一、周二、周三……】
Map<int, String> weekDayToZhouJi = {
  0: '周一',
  1: '周二',
  2: '周三',
  3: '周四',
  4: '周五',
  5: '周六',
  6: '周日',
};

/// 大时间段到**开始的**节次（一天最多只有 5 门课（大概），有 11 个节次的课）(0=>1, 1=>3, 2=>5, 3=>7, 4=>9)
Map<int, int> classCountToSection = {
  0: 1,
  1: 3,
  2: 5,
  3: 7,
  4: 9,
};

/// 格式化（美化） Json
///
/// 传入一定要是 json 类型，如果是 String 需要先 decode。
String formatJsonEncode(dynamic json) {
  var spaces = ' ' * 4;
  var encoder = JsonEncoder.withIndent(spaces);
  return encoder.convert(json);
}

/// 文件名对应的用途、意义
Map fileNameToMeaning = {
  'cultivate_plan.json': '培养方案',
  'exam_time.json': '考试时间',
};
