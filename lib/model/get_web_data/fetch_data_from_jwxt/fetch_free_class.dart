import 'package:sachet/provider/user_provider.dart';
import 'package:sachet/model/get_web_data/fetch_data_from_jwxt/dio_get_post_jwxt.dart';

/// 从教务系统网站获取空闲教室数据
Future fetchFreeClassData(int isTomorrow) async {
  return await dioPOSTjwxt(
    url: 'https://jwxt.xtu.edu.cn/jsxsd/kbxx/kxjs_query',
    data: {
      'cj0701id': '',
      'xqbh': '',
      'jxlbh': '',
      'jsbh': '',
      'xzlx': '$isTomorrow'
    },
    headers: {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Cache-Control': 'max-age=0',
      'Connection': 'keep-alive',
      // 'Content-Length': '35',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': UserProvider.cookie,
      'Host': 'jwxt.xtu.edu.cn',
      'Refer': 'https://jwxt.xtu.edu.cn/jsxsd/kbxx/kxjs_query',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    },
  );
}
