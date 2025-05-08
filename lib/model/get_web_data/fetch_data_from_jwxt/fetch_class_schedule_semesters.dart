import 'package:sachet/provider/user_provider.dart';
import 'package:sachet/model/get_web_data/fetch_data_from_jwxt/dio_get_post_jwxt.dart';

/// 从教务系统网站获取课表可选学期和当前学期
Future<String> fetchClassScheduleSemestersData() async {
  return await dioGETjwxt(
    url: 'https://jwxt.xtu.edu.cn/jsxsd/xskb/xskb_list.do',
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
