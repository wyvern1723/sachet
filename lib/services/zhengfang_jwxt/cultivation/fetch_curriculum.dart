import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

/// 获取培养方案查询的某专业的课程信息
Future fetchCurriculumZF({
  required String cookie,
  required String queryMajorId,
}) async {
  final dio = Dio(BaseOptions(
    validateStatus: (_) => true,
    followRedirects: false,
  ));

  final String nd = DateTime.now().millisecondsSinceEpoch.toString();

  final Map<String, String> data = {
    "jyxdxnm": "",
    "jyxdxqm": "",
    "yxxdxnm": "",
    "yxxdxqm": "",
    "shzt": "",
    "kch": "",
    "jxzxjhxx_id": queryMajorId,
    "xdlx": "",
    "_search": "false",
    "nd": nd,
    "queryModel.showCount": "1000", // 每页最多条数
    "queryModel.currentPage": "1",
    "queryModel.sortName": "jyxdxnm,jyxdxqm,kch ",
    "queryModel.sortOrder": "asc",
    "time": "0" // 查询次数
  };

  try {
    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/jxzxjhgl/jxzxjhkcxx_cxJxzxjhkcxxIndex.html?doType=query&gnmkdm=N153540',
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
        // 'Content-Length': '191',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer':
            'https://jw.xtu.edu.cn/jwglxt/jxzxjhgl/jxzxjhck_cxJxzxjhckIndex.html?gnmkdm=N153540&layout=default',
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
      throw '返回的课程信息格式不是 json';
    }

    return (response.data);
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取课程信息失败: $errorTypeText';
  } catch (e) {
    throw '获取课程信息失败: $e';
  }
}
