import 'package:dio/dio.dart';

Future fetchSemesterStartDate({required String cookie}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  try {
    Response response = await dio.get(
      'https://jw.xtu.edu.cn/jwglxt/xtgl/index_cxAreaFive.html?localeKey=zh_CN&gnmkdm=index',
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer': 'https://jw.xtu.edu.cn/jwglxt/xtgl/login_slogin.html',
        // 'Referer': 'https://jw.xtu.edu.cn/jwglxt/xtgl/index_initMenu.html?jsdm=&_t=1757309850925&echarts=1',
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
  } catch (e) {
    throw '获取学期开始日期失败: $e';
  }
}
