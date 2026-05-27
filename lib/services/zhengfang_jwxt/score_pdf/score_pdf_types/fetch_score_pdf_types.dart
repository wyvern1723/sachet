import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

/// 获取可选的成绩单格式
///
/// 返回的 html 包含
///
/// ```html
/// <option value="10530-zw-zgmrgs">中文主修成绩单（最高考虑加分）</option>
/// <option value="10530-zw-qcmrgs">中文主修成绩单（全程）</option>
/// <option value="10530-zw-zgbjf">中文主修成绩单（最高不考虑加分）</option>
/// ```
Future fetchScorePdfTypesZF({required String cookie}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  final params = {
    "mapper[jg_id]": "jg_id",
    "mapper[zyh_id]": "zyh_id",
    "mapper[bh_id]": "bh_id",
    "mapper[njdm_id]": "njdm_id"
  };
  try {
    final String nd = DateTime.now().millisecondsSinceEpoch.toString();

    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/bysxxcx/xscjzbdy_dyXscjzbView.html?dyly=dy&time=$nd&gnmkdm=N558020',
      data: FormData.fromMap(params),
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': 'text/html, */*; q=0.01',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        // 'Content-Length': '101',
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

    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取可选成绩单格式失败: $errorTypeText';
  } catch (e) {
    throw '获取可选成绩单格式失败: $e';
  }
}
