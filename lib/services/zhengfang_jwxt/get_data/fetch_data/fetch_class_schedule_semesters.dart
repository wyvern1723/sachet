import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

Future fetchClassScheduleSemetersZF({required String cookie}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  try {
    Response response = await dio.get(
      'https://jw.xtu.edu.cn/jwglxt/kbcx/xskbcx_cxXskbcxIndex.html?gnmkdm=N2151',
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Connection': 'keep-alive',
        'Cookie': cookie,
        'Upgrade-Insecure-Requests': '1',
        // 'Sec-Fetch-Dest': 'document',
        // 'Sec-Fetch-Mode': 'navigate',
        // 'Sec-Fetch-Site': 'none',
        // 'Sec-Fetch-User': '?1',
        // 'Priority': 'u=0, i',
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
    throw '获取课表学期数据失败: $errorTypeText';
  } catch (e) {
    throw '获取课表学期数据失败: $e';
  }
}
