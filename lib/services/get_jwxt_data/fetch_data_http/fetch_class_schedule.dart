import 'package:sachet/providers/user_provider.dart';
import 'package:sachet/services/get_jwxt_data/fetch_data_http/dio_get_post_jwxt.dart';

/// 从教务系统网站获取课表数据
///
/// weekCount: 1-30(?); semester: 2023-2024-1/2023-2024-2/2024-2025-1/2024-2025-2
Future fetchClassSchedule({
  required int weekCount,
  required String semester,
}) async {
  // 下学期的需要 post
  // 默认的直接 get 就行，
  // refer https://jwxt.xtu.edu.cn/jsxsd/pyfa/pyfazd_query?Ves632DSdyV=NEW_XSD_PYGL

  return await dioPOSTjwxt(
    url: 'https://jwxt.xtu.edu.cn/jsxsd/xskb/xskb_list.do',
    data: {
      'cj0701id': '',
      'zc': '$weekCount',
      'demo': '',
      'xnxq01id': '$semester',
      'sfFD': '1'
    },
    headers: {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Cache-Control': 'max-age=0',
      'Connection': 'keep-alive',
      // 'Content-Length': '37',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': UserProvider.cookie,
      'Host': 'jwxt.xtu.edu.cn',
      'Origin': 'https://jwxt.xtu.edu.cn',
      'Refer': 'https://jwxt.xtu.edu.cn/jsxsd/xskb/xskb_list.do',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    },
  );
}
