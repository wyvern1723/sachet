import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

Future<Map> fetchGradeZF({
  required String cookie,

  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年, ""=> 全部
  required String semesterYear,

  /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期, ""=> 全部
  required String semesterIndex,
}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  try {
    final String nd = DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, String> data = {
      "xnm": semesterYear, // 学年数
      "xqm": semesterIndex, // 学期数，第一学期为3，第二学期为12, 整个学年为空''
      "sfzgcj": "", // 是否??成绩，可填 "ck"
      "kcbj": "", // 课程标记，有“主修”:"1"，“辅修”:"2"，“二专业”:"3"……
      "_search": "false",
      "nd": nd,
      "queryModel.showCount": "999", // 每页最多条数
      "queryModel.currentPage": "1",
      // TODO: "queryModel.sortName": "+"
      // 浏览器 POST Data 为 "queryModel.sortName": "+",
      // 但是如果使用 curl 及 dart 的 Dio 等发送 "queryModel.sortName": "+" 会返回
      // “出错啦！ 系统运行异常，请稍后再试” 的错误页面 HTML，（原期待返回为 json）
      // 发现发送 "queryModel.sortName": "" 不会出错，原因未知。
      //
      // 如果直接发送 jsonContentType，而不是 formUrlEncodedContentType，不会返回 “出错啦！ 系统运行异常，请稍后再试” 的错误页面 HTML，
      // 但返回的 json 数据的成绩信息始终为空:
      // {currentPage: 1, currentResult: 0, entityOrField: false, items: [], limit: 15, offset: 0, pageNo: 0, pageSize: 15, showCount: 10, sortName: xnmmc asc,xqmmc asc,kch asc, sortOrder:  , sorts: [], totalCount: 0, totalPage: 0, totalResult: 0}
      "queryModel.sortName": "",
      "queryModel.sortOrder": "asc",
      "time": "0" // 查询次数
    };

    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/cjcx/cjcx_cxXsgrcj.html?doType=query&gnmkdm=N305005',
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
        // 'Content-Length': '162',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer':
            'https://jw.xtu.edu.cn/jwglxt/cjcx/cjcx_cxDgXscj.html?gnmkdm=N305005&layout=default',
        'Cookie': cookie,
        // 'Sec-Fetch-Dest': 'empty',
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
    if (response.statusCode != 200) {
      throw 'Http status code = ${response.statusCode}';
    }
    if (response.data is! Map) {
      throw '返回的成绩数据格式不是 json';
    }

    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取成绩数据失败: $errorTypeText';
  } catch (e) {
    throw '获取成绩数据失败: $e';
  }
}
