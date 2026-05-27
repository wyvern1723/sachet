import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

/// 获取成绩单链接
///
/// return: "/jwglxt/templete/scorePrint/score_202312345678_1769943281937.pdf#成功"
Future fetchScorePdfLinkZF({
  required String cookie,

  /// 成绩单格式
  ///
  /// e.g.,
  /// "中文主修成绩单（最高考虑加分）": "10530-zw-zgmrgs",
  /// "中文主修成绩单（全程）": "10530-zw-qcmrgs",
  /// "中文主修成绩单（最高不考虑加分）": "10530-zw-zgbjf"
  required String type,
}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));

  final params = {
    "gsdygx": type,
    "ids": "",
    "bdykcxzDms": "",
    "cytjkcxzDms": "",
    "cytjkclbDms": "",
    "cytjkcgsDms": "",
    "bjgbdykcxzDms": "",
    "bjgbdyxxkcxzDms": "",
    "djksxmDms": "",
    "cjbzmcDms": "",
    "zdyfsxmDms": "",
    "bdymaxcjbzmcDms": "",
    "cjdySzxs": "",
    "wjlx": "pdf"
  };

  try {
    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/bysxxcx/xscjzbdy_dyList.html?gnmkdm=N558020',
      data: FormData.fromMap(params),
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        // 'Content-Length': '180',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer':
            'https://jw.xtu.edu.cn/jwglxt/bysxxcx/xscjzbdy_cxXscjzbdyIndex.html?gnmkdm=N558020&layout=default',
        'Cookie': cookie,
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
      }),
    );

    if (response.statusCode == 901) {
      throw 'Http status code = 901, 验证身份信息失败';
    }
    if (response.statusCode != 200) {
      throw 'Http status code = ${response.statusCode}';
    }

    return (response.data);
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取成绩单链接失败: $errorTypeText';
  } catch (e) {
    throw '获取成绩单链接失败: $e';
  }
}
