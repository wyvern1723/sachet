import 'package:sachet/providers/user_provider.dart';
import 'package:sachet/services/get_jwxt_data/fetch_data_http/dio_get_post_jwxt.dart';

/// 从教务系统网站获取成绩查询可选学期和当前学期
Future<String> fetchExamTimeSemestersData() async {
  return await dioGETjwxt(
    url:
        'https://jwxt.xtu.edu.cn/jsxsd/xsks/xsksap_query?Ves632DSdyV=NEW_XSD_KSBM',
    headers: {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Host': 'jwxt.xtu.edu.cn',
      'Referer':
          'https://jwxt.xtu.edu.cn/jsxsd/pyfa/pyfazd_query?Ves632DSdyV=NEW_XSD_PYGL',
      'Cookie': UserProvider.cookie,
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    },
  );
}
