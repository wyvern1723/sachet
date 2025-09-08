// 变换、映射关系

import 'dart:convert';

import 'package:dio/dio.dart';

/// 【1,2,3...】 => 【星期一、星期二、星期三……】
Map<int, String> weekdayToXingQiJi = {
  1: '星期一',
  2: '星期二',
  3: '星期三',
  4: '星期四',
  5: '星期五',
  6: '星期六',
  7: '星期日',
};

/// 【1,2,3...】 => 【周一、周二、周三……】
Map<int, String> weekdayToZhouJi = {
  1: '周一',
  2: '周二',
  3: '周三',
  4: '周四',
  5: '周五',
  6: '周六',
  7: '周日',
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

Map<DioExceptionType, String> dioExceptionTypeToText = {
  DioExceptionType.connectionTimeout: "连接超时",
  DioExceptionType.sendTimeout: "发送超时",
  DioExceptionType.receiveTimeout: "接收超时",
  DioExceptionType.badCertificate: "证书错误",
  DioExceptionType.badResponse: "错误响应",
  DioExceptionType.cancel: "请求取消",
  DioExceptionType.connectionError: "连接错误",
  DioExceptionType.unknown: "未知错误",
};
