import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

/// 获取培养方案选择学院后查询的学院下专业列表(学院下属专业)
///
/// return: List json
Future fetchCultivationSchoolMajorsZF({
  required String cookie,
  required String shoolId,
}) async {
  final dio = Dio(BaseOptions(
    validateStatus: (_) => true,
    followRedirects: false,
  ));
  final String nd = DateTime.now().millisecondsSinceEpoch.toString();

  try {
    Response response = await dio.get(
      'https://jw.xtu.edu.cn/jwglxt/xtgl/comm_cxZydmList.html?jg_id=$shoolId&_=$nd&gnmkdm=N153540',
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'X-Requested-With': 'XMLHttpRequest',
        'Connection': 'keep-alive',
        'Refer':
            'https://jw.xtu.edu.cn/jwglxt/jxzxjhgl/jxzxjhck_cxJxzxjhckIndex.html?gnmkdm=N153540&layout=default',
        'Cookie': cookie,
        // 'Sec-Fetch-Dest': 'em pty',
        // 'Sec-Fetch-Mode': 'cors',
        // 'Sec-Fetch-Site': 'same-origin',
        // 'Priority': 'u=0',
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
      }),
    );

    if (response.statusCode == 901) {
      throw 'Http status code = 901, 验证身份信息失败';
    }
    if (response.statusCode == 302) {
      throw 'Http status code = 302, 可能需要重新登录';
    }
    if (response.statusCode != 200) {
      throw 'Http status code = ${response.statusCode}';
    }
    if (response.data is! List) {
      throw '返回的专业列表格式错误';
    }

    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取培养方案学院下属专业列表失败: $errorTypeText';
  } catch (e) {
    throw '获取培养方案学院下属专业列表失败: $e';
  }
}
