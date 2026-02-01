import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

Future<Map> fetchGPAZF({
  required String cookie,

  /// 起始学年学期，如 "202503", "202512"
  required String startSemester,

  /// 终止学年学期，如 "202503", "202512"
  required String endSemester,

  /// 课程属性. 全部: "", 必修: "bx", 选修: "xx"
  required String courseType,
}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  try {
    final String nd = DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, String> data = {
      "qsXnxq": startSemester, // 起始学年学期
      "zzXnxq": endSemester, // 终止学年学期
      "xbx": "bx", // 课程属性  全部: "", 必修: "bx", 选修: "xx"
      "_search": "false",
      "nd": nd,
      "queryModel.showCount": "50", // 每页最多条数
      "queryModel.currentPage": "1",
      "queryModel.sortName": "xh+",
      "queryModel.sortOrder": "asc",
      "time": "0" // 查询次数
    };

    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/cjpmtj/cjpmtj_cxPjxfjdpmtjIndex.html?doType=query&gnmkdm=N309104',
      data: data,
      options: Options(
        headers: {
          'Host': 'jw.xtu.edu.cn',
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
          'Accept': 'application/json, text/javascript, */*; q=0.01',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate, br, zstd',
          'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          // 'Content-Length': '170',
          'Origin': 'https://jw.xtu.edu.cn',
          'Connection': 'keep-alive',
          'Referer':
              'https://jw.xtu.edu.cn/jwglxt/cjpmtj/cjpmtj_cxPjxfjdpmtjIndex.html?gnmkdm=N309104&layout=default',
          'Cookie': cookie,
          // 'Sec-Fetch-Dest': 'empty',
          // 'Sec-Fetch-Mode': 'cors',
          // 'Sec-Fetch-Site': 'same-origin',
          // 'Priority': 'u=0',
          'Pragma': 'no-cache',
          'Cache-Control': 'no-cache',
        },
        receiveTimeout:
            Duration(seconds: 25), // 教务系统获取绩点排名数据很慢，8s~20s 不等。Dio 超时默认 5s 是不够的。
      ),
    );

    if (response.statusCode == 901) {
      throw 'Http status code = 901, 验证身份信息失败';
    }
    if (response.statusCode != 200) {
      throw 'Http status code = ${response.statusCode}';
    }
    if (response.data is! Map) {
      throw '返回的数据格式不是 json';
    }

    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取绩点排名数据失败: $errorTypeText';
  } catch (e) {
    throw '获取绩点排名数据失败: $e';
  }
}
