import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

Future<Map> fetchExperimentCourseZF({
  required String cookie,

  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年
  required String semesterYear,

  /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期
  required String semesterIndex,
}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));

  try {
    final String nd = DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, String> data = {
      "xnm": semesterYear,
      "xqm": semesterIndex,
      "kzlx": "ck",
      "xsdm": '',
      "kclbdm": '',
      "kclxdm": '',
      "_search": "false",
      "nd": nd,
      "queryModel.showCount": "1000",
      "queryModel.currentPage": "1",
      "queryModel.sortName": "",
      "queryModel.sortOrder": "asc",
      "time": "0", // 查询次数
    };

    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/xssygl/sykbcx_cxSykbcxxsIndex.html?doType=query&gnmkdm=N2151',
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
        // 'Content-Length': '179',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer':
            'https://jw.xtu.edu.cn/jwglxt/kbcx/xskbcx_cxXskbcxIndex.html?gnmkdm=N2151&layout=default',
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
      throw '返回的实验课表数据格式不是 json';
    }
    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取实验课表数据失败: $errorTypeText';
  } catch (e) {
    throw '获取实验课表数据失败: $e';
  }
}
