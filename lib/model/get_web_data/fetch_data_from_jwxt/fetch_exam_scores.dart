import 'package:sachet/provider/user_provider.dart';
import 'package:sachet/model/get_web_data/fetch_data_from_jwxt/dio_get_post_jwxt.dart';

/// 从教务系统网站获取成绩查询的可选择学期
Future fetchGradeSemesterData() async {
  return await dioGETjwxt(
    url: 'https://jwxt.xtu.edu.cn/jsxsd/kscj/cjcx_query',
    headers: {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Host': 'jwxt.xtu.edu.cn',
      'Cookie': UserProvider.cookie,
      'Proxy-Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    },
  );
}

/// 从教务系统网站获取考试成绩数据
Future<String> fetchExamScoresGradeData(String semester) async {
  return await dioPOSTjwxt(
    url: 'https://jwxt.xtu.edu.cn/jsxsd/kscj/cjcx_list',
    data: {'kksj': semester, 'kclb': '', 'kcmc': '', 'xsfs': 'all'},
    queryParameters: {"xq": semester},
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
      'Refer': 'https://jwxt.xtu.edu.cn/jsxsd/kscj/cjcx_query',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    },
  );
}

/// 从教务系统网站获取 GPA 和排名数据
Future fetchGPAandRankData(String semester) async {
  return await dioPOSTjwxt(
    url: 'https://jwxt.xtu.edu.cn/jsxsd/kscj/cjjd_list',
    data: {'kksj': semester, 'kclb': '1', 'zsb': ''},
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
      'Origin': 'https://jwxt.xtu.edu.cn',
      'Refer': 'https://jwxt.xtu.edu.cn/jsxsd/kscj/cjjd_cx',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    },
  );
}

/// 从教务系统网站获取平时分数据
Future<String> fetchGeneralPerformanceMarksData(String detailsUrl) async {
  return await dioGETjwxt(
    url: 'https://jwxt.xtu.edu.cn$detailsUrl',
    headers: {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Cache-Control': 'max-age=0',
      'Connection': 'keep-alive',
      'Cookie': UserProvider.cookie,
      'Host': 'jwxt.xtu.edu.cn',
      'Referer': 'https://jwxt.xtu.edu.cn/jsxsd/kscj/cjcx_list?xq=null',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
    },
  );
}
