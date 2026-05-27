import 'package:dio/dio.dart';

/// return
///
/// e.g.
///
/// ```
///  [
///        {
///            "XQH_ID": "02",
///            "JXLDM": "209",
///            "JXLMC": "北山画室"
///        },
///        {
///            "XQH_ID": "02",
///            "JXLDM": "206",
///            "JXLMC": "北山阶梯"
///        },
///        {
///            "XQH_ID": "02",
///            "JXLDM": "907",
///            "JXLMC": "材料大楼"
///        },
///        {
///            "XQH_ID": "02",
///            "JXLDM": "902",
///            "JXLMC": "测试中心"
///        },
///        {
///            "XQH_ID": "02",
///            "JXLDM": "109",
///            "JXLMC": "第二教学楼"
///        },
///        {
///            "XQH_ID": "02",
///            "JXLDM": "201",
///            "JXLMC": "第三教学楼"
///        },
///        {
///            "XQH_ID": "02",
///            "JXLDM": "101",
///            "JXLMC": "第一教学楼"
///        }
/// ]
/// ```
Future<List> fetchTeachingBuildingsZF({
  required String cookie,

  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年
  required String semesterYear,

  /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期
  required String semesterIndex,
}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  try {
    Response response = await dio.get(
      'https://jw.xtu.edu.cn/jwglxt/cdjy/cdjy_cxXqjc.html',
      queryParameters: {
        "xqh_id": "02", // 校区 id "02"=> 校本部，"03"=> 兴湘学院 (但兴湘学院并无数据)
        "xnm": semesterYear,
        "xqm": semesterIndex,
        "gnmkdm": "N2155",
      },
      options: Options(headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        "Accept": "application/json, text/javascript, */*; q=0.01",
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'X-Requested-With': 'XMLHttpRequest',
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
      throw '返回的数据格式不是 json';
    }

    return response.data['lhList'];
  } catch (e) {
    throw '获取可选教学楼失败: $e';
  }
}
