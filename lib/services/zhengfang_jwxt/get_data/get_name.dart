import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'package:sachet/utils/transform.dart';

/// 从正方教务系统获取姓名
Future<String> getNameZF(String cookie) async {
  final String html = await fetchNameZF(cookie);
  final String name = extractNameFromHtmlZF(html);
  return name;
}

Future<String> fetchNameZF(String cookie) async {
  final dio = Dio(BaseOptions(
    validateStatus: (_) => true,
  ));
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    Response response = await dio.get(
      'https://jw.xtu.edu.cn/jwglxt/xtgl/index_cxYhxxIndex.html',
      queryParameters: {
        "xt": "jw",
        "localeKey": "zh_CN",
        "_": "$timestamp",
        "gnmkdm": "index",
      },
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': 'text/html, */*; q=0.01',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'Connection': 'keep-alive',
        // 'Referer': 'https://jw.xtu.edu.cn/jwglxt/xtgl/index_initMenu.html?jsdm=&_t=1755930428191&echarts=1',
        'Referer': 'https://jw.xtu.edu.cn/jwglxt/xtgl/index_initMenu.html',
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
    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw Exception('$errorTypeText');
  } catch (e) {
    throw Exception('$e');
  }
}

String extractNameFromHtmlZF(String html) {
  final document = parse(html);

  // <h4 class="media-heading">张三&nbsp;&nbsp;学生</h4>
  final element = document.getElementsByClassName('media-heading');
  if (element.isEmpty) {
    return '';
  }

  return (element[0].text.split('\u00A0')[0]);
}
