import 'package:sachet/provider/user_provider.dart';
import 'package:sachet/model/get_web_data/fetch_data_from_jwxt/dio_get_post_jwxt.dart';

/// 从教务系统网站获取考试时间数据
Future fetchExamTimeData(String semester) async {
  return await dioPOSTjwxt(
    url: 'https://jwxt.xtu.edu.cn/jsxsd/xsks/xsksap_list',
    data: {'xqlbmc': '', 'xnxqid': semester, 'xqlb': ''},
    headers: {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Cache-Control': 'max-age=0',
      'Connection': 'keep-alive',
      // 'Content-Length': '32',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': UserProvider.cookie,
      'Host': 'jwxt.xtu.edu.cn',
      'Origin': 'https://jwxt.xtu.edu.cn',
      'Referer':
          'https://jwxt.xtu.edu.cn/jsxsd/xsks/xsksap_query?Ves632DSdyV=NEW_XSD_KSBM',
    },
  );
}
