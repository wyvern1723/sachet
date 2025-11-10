import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

/// 获取考试时间（正方教务系统）
Future<Map> fetchExamTimeZF({
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
      "xnm": semesterYear, // 学年名，如 '2025'=> 指 2025-2026 学年
      "xqm": semesterIndex, // 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期, ""=> 全部
      // 考试名称
      // <option value="">全部</option>
      // <option value="400D4D424CBA2552E063C94418AC6F2B">（本部）2025-2026第一学期课程考试(校本部)</option>
      // <option value="41407A4E677AC4C6E063CA4418ACC121">（本部）重考重修排考(校本部)</option>
      // <option value="400D4D424CBF2552E063C94418AC6F2B">（兴湘）2025-2026第一学期课程考试(校本部)</option>
      // <option value="425DAA2BCCC1BDC0E063CA4418AC5F8E">（兴湘）2025-2026课程考试提前考(校本部)</option>
      // <option value="41407A4E6797C4C6E063CA4418ACC121">（兴湘）重考重修排考(校本部)</option>
      "ksmcdmb_id": "",
      "kch": "", // 课程号
      "kc": "",
      "ksrq": "", // 考试时间（考试日期）
      // 开课学院
      // <option value="">全部</option>
      // <option value="013">商学院</option>
      // <option value="001">马克思主义学院</option>
      // <option value="037">文学与新闻学院</option>
      // <option value="031">外国语学院</option>
      // <option value="043">艺术学院</option>
      // <option value="019">公共管理学院</option>
      // <option value="075">数学与计算科学学院</option>
      // <option value="071">物理与光电工程学院</option>
      // <option value="060">化学学院</option>
      // <option value="072">材料科学与工程学院</option>
      // <option value="065">化工学院</option>
      // <option value="088">体育教学部</option>
      // <option value="096">兴湘学院</option>
      // <option value="097">环境与资源学院</option>
      // <option value="002">哲学与历史文化学院（碧泉书院）</option>
      // <option value="050">机械工程与力学学院</option>
      // <option value="080">土木工程学院</option>
      // <option value="555">创业学院</option>
      // <option value="35D97F199E9D41D4E063C94418ACC2FB">法学学部</option>
      // <option value="360274A015EFD598E063CB4418AC55B9">卓越工程师学院</option>
      // <option value="125">学生工作部、人民武装部</option>
      // <option value="208">教务处</option>
      // <option value="126">招生与就业指导处</option>
      // <option value="252">保卫处</option>
      // <option value="401">图书馆</option>
      // <option value="256">后勤保障处</option>
      // <option value="230">工程教学部</option>
      // <option value="214500">实验室与资产管理处</option>
      // <option value="098">湖南先进传感与信息技术创新研究院</option>
      // <option value="056">计算机学院●网络空间安全学院</option>
      // <option value="057">自动化与电子信息学院</option>
      // <option value="085">国际交流学院</option>
      "kkbm_id": "",
      "_search": "false",
      "nd": nd,
      "queryModel.showCount": "99", // 每页最多条数
      "queryModel.currentPage": "1",
      "queryModel.sortName": "",
      "queryModel.sortOrder": "asc",
      "time": "0", // 查询次数
    };

    Response response = await dio.post(
      'https://jw.xtu.edu.cn/jwglxt/kwgl/kscx_cxXsksxxIndex.html?doType=query&gnmkdm=N358105',
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
        // 'Content-Length': '184',
        'Origin': 'https://jw.xtu.edu.cn',
        'Connection': 'keep-alive',
        'Referer':
            'https://jw.xtu.edu.cn/jwglxt/kwgl/kscx_cxXsksxxIndex.html?gnmkdm=N358105&layout=default',
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
      throw '返回的考试时间数据格式不是 json';
    }

    return response.data;
  } on DioException catch (e) {
    String? errorTypeText = dioExceptionTypeToText[e.type];
    if (kDebugMode) {
      print(e);
    }
    throw '获取考试时间数据失败: $errorTypeText';
  } catch (e) {
    throw '获取考试时间数据失败: $e';
  }
}
