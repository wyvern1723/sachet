import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

Future<Map> fetchClassScheduleZF({
  required String cookie,

  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年
  required String semesterYear,

  /// xqm 学期名，1=> 第1学期，2=>第二学期，3=>第三学期
  required String semesterIndex,
}) async {
  Map<String, String> indexToXnm = {
    '1': '3',
    '2': '12',
    '3': '16',
  };
  final dio = Dio(BaseOptions(
    validateStatus: (_) => true,
  ));
  try {
    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/kbcx/xskbcx_cxXsgrkb.html?gnmkdm=N2151',
      data: {
        "xnm": semesterYear,
        "xqm": indexToXnm[semesterIndex],
        "kzlx": "ck",
        "xsdm": "",
        "kclbdm": ""
      },
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        // 'Content-Length': '36',
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
      throw 'Http status code = 901: 验证身份信息失败';
    }
    if (response.statusCode != 200) {
      throw 'Http status code = ${response.statusCode}';
    }
    if (response.data is! Map) {
      throw '返回的课程表数据格式不是 json';
    }

    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw Exception('获取课表数据失败: $errorTypeText');
  } catch (e) {
    throw Exception('获取课表数据失败: $e');
  }
}
