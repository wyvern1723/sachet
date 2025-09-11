import 'package:dio/dio.dart';

Future<List> fetchFreeClassroomZF({
  required String cookie,
  required Map data,
}) async {
  final dio = Dio(BaseOptions(
    validateStatus: (_) => true,
  ));
  try {
    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/cdjy/cdjy_cxKxcdlb.html?doType=query&gnmkdm=N2155',
      data: data,
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        // 'Content-Length': '36',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer':
            'https://jw.xtu.edu.cn/jwglxt/cdjy/cdjy_cxKxcdlb.html?gnmkdm=N2155&layout=default',
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
      throw '格式错误';
    }
    return response.data['items'];
  } catch (e) {
    throw '获取空闲教室数据失败: $e';
  }
}
