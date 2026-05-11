import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

/// 获取教材预订的教材信息
///
/// return: json 格式的数据
Future fetchReserveTextbookInfoZF({
  required String cookie,

  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年, ""=> 全部
  required String semesterYear,

  /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，""=> 全部
  required String semesterIndex,
}) async {
  final dio = Dio(BaseOptions(
    validateStatus: (_) => true,
    followRedirects: false,
  ));
  try {
    final String nd = DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, String> data = {
      "xnm": semesterYear,
      "autocomplete": "",
      "xqm": semesterIndex,
      "kch": "",
      "jcmc": "",
      "jczz": "",
      "cbs": "",
      "bbh": "",
      "isbn": "",
      "doType": "query",
      "_search": "false",
      "nd": nd,
      "queryModel.showCount": "100", // 每页最多条数
      "queryModel.currentPage": "1",
      "queryModel.sortName": "xnmmc,xqmmc,kcmc,jcmc+",
      "queryModel.sortOrder": "asc",
      "time": "0" // 查询次数
    };

    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/jcydgl/xsjcyd_cxXsjcydIndex.html?gnmkdm=N253545',
      data: data,
      options: Options(headers: {
        'Host': 'jw.xtu.edu.cn',
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        // 'Content-Length': '236',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer':
            'https://jw.xtu.edu.cn/jwglxt/jcydgl/xsjcyd_cxXsjcydIndex.html?gnmkdm=N253545&layout=default',
        'Cookie': cookie,
        // 'Sec-Fetch-Dest': 'empty',
        // 'Sec-Fetch-Mode': 'cors',
        // 'Sec-Fetch-Site': 'same-origin',
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
    if (response.data is! Map) {
      throw '返回的教材预订信息格式不是 json';
    }

    return (response.data);
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取教材预订信息失败: $errorTypeText';
  } catch (e) {
    throw '获取教材预订信息失败: $e';
  }
}
