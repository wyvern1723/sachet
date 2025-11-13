import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:html/parser.dart';
import 'package:sachet/models/login_response_status.dart';

class QiangZhiLoginService {
  // ***********************************
  // 001 set-cookie —— 第一次访问网址，得到服务器为我们分配的 'set-cookie'
  // ***********************************
  /// 获取初始 cookie
  Future<String> getCookie() async {
    try {
      var getCookieResponse = await Dio().get(
        'https://jwxt.xtu.edu.cn/jsxsd/',
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Encoding': 'gzip, deflate',
            'Accept-Language': 'zh-CN,zh;q=0.9',
            'Host': 'jwxt.xtu.edu.cn',
            'Proxy-Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
          },
        ),
      );
      String cookie;
      // TODO 检查 getCookieResponse.headers['set-cookie']，否则 type 'Null' is not a subtype of type 'List<int>'
      if (getCookieResponse.statusCode == 200) {
        cookie = getCookieResponse.headers['set-cookie']![0]
            .toString()
            .split(';')[0];
        // print(getCookieResponse.headers);
      } else {
        throw Exception('statusCode = ${getCookieResponse.statusCode}');
      }
      return cookie;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  // ****************************************
  // 002 获取验证码图片 —— 带着前一步得到的 cookie 获取验证码图片
  // ****************************************
  /// 获取验证码图片
  Future<Uint8List> getVerifyCodeImg(String cookie) async {
    try {
      var verifycodeResponse = await Dio().get(
        'https://jwxt.xtu.edu.cn/jsxsd/verifycode.servlet',
        options: Options(
          headers: {
            'accept':
                'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
            'accept-encoding': 'gzip, deflate',
            'accept-language': 'zh-CN,zh;q=0.9',
            'cookie': cookie,
            'host': 'jwxt.xtu.edu.cn',
            'proxy-connection': 'keep-alive',
            'referer': 'https://jwxt.xtu.edu.cn/jsxsd/',
            'user-agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
          },
          responseType: ResponseType.bytes,
        ),
      );
      if (verifycodeResponse.data != null) {
        return verifycodeResponse.data;
      } else {
        throw Exception('response data is null');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  // ****************************************
  // 003 得到 encoded —— POST 用户名和密码，得到 'data'，再进行加密，得到 'encoded'
  // ****************************************
  Future<String> getEncoded(
      String username, String password, String cookie) async {
    try {
      var encodeResponse = await Dio().post(
        'https://jwxt.xtu.edu.cn/jsxsd/xk/LoginToXk?flag=sess',
        data: {'USERNAME': username, 'PASSWORD': password},
        options: Options(
          headers: {
            'Accept': 'application/json, text/javascript, */*; q=0.01',
            'Accept-Encoding': 'gzip, deflate',
            'Accept-Language': 'zh-CN,zh;q=0.9',
            // 'Content-Length': '0',
            'Cookie': cookie,
            'Host': 'jwxt.xtu.edu.cn',
            'Origin': 'https://jwxt.xtu.edu.cn',
            'Proxy-Connection': 'keep-alive',
            'Referer': 'https://jwxt.xtu.edu.cn/jsxsd/',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
            'X-Requested-With': 'XMLHttpRequest',
          },
          // sendTimeout: Duration(seconds: 5),
          // receiveTimeout: Duration(seconds: 3),
        ),
      );
      var data = encodeResponse.data;
      data = jsonDecode(data)['data'];
      var scode = data.split('#')[0];
      var sxh = data.split("#")[1];
      var code = '$username%%%$password';
      var encoded = '';
      for (var i = 0; i < code.length; i++) {
        if (i < 20) {
          encoded = encoded +
              code.substring(i, i + 1) +
              scode.substring(0, int.parse(sxh.substring(i, i + 1)));
          scode =
              scode.substring(int.parse(sxh.substring(i, i + 1)), scode.length);
        } else {
          encoded = encoded + code.substring(i, code.length);
          i = code.length;
        }
      }
      return encoded;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('getEncoded Failed');
        print("error : ${e.response?.data}");
      }
      return 'getEncoded Failed';
    }
  }

  /// 确认登录成功（并返回 用户信息）
  Future<List> confirmLogin(String cookie) async {
    try {
      var response = await Dio().get(
        "https://jwxt.xtu.edu.cn/jsxsd/framework/xsMain.jsp",
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Encoding': 'gzip, deflate',
            'Accept-Language': 'zh-CN,zh;q=0.9',
            'cache-control': 'max-age=0',
            'connection': 'keep-alive',
            'Cookie': cookie,
            'Host': 'jwxt.xtu.edu.cn',
            'Proxy-Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
          },
        ),
      );
      if (kDebugMode) {
        print(response.headers);
        print(cookie);
      }
      List nameAndID = await getNameAndStudentIDFromHtml(response.data);
      return nameAndID;
    } on DioException catch (e) {
      if (kDebugMode) {
        // String data = gbk.decode(e.response?.data);
        print("error : $e");
      }
      return [LoginResponseStatus.unknowError];
    }
  }

  // ****************************************
  // 004 登录 —— POST 用户名、密码、encoded、验证码
  // ****************************************

  /// 登录 Post
  ///
  /// 登录失败(200)，返回 [LoginResponseStatus.failed,errorInfo]
  ///
  /// 登录成功(302)，返回 [LoginResponseStatus.success, 姓名,学号]
  ///
  /// 用初始密码登录成功(302)，需要重设密码返回 [LoginResponseStatus.needResetPassword]
  ///
  /// 未知错误(302)，返回 [LoginResponseStatus.unknowError]
  ///
  /// 其他 statusCode，返回 [LoginResponseStatus.otherStatusCode, statusCode]
  ///
  Future<List> loginPost(String username, String password, String randomcode,
      String cookie) async {
    try {
      String encoded = await getEncoded(username, password, cookie);
      var loginResponse = await Dio().post(
        'https://jwxt.xtu.edu.cn/jsxsd/xk/LoginToXk',
        data: {
          'USERNAME': username,
          'PASSWORD': password,
          'encoded': encoded,
          'RANDOMCODE': randomcode,
        },
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Encoding': 'gzip, deflate',
            'Accept-Language': 'zh-CN,zh;q=0.9',
            'Cache-Control': 'max-age=0',
            // 'Content-Length': '110',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Cookie': cookie,
            'Host': 'jwxt.xtu.edu.cn',
            'Origin': 'https://jwxt.xtu.edu.cn',
            'Proxy-Connection': 'keep-alive',
            'Referer': 'https://jwxt.xtu.edu.cn/jsxsd/',
            'Upgrade-Insecure-Requests': '1',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
          },
          responseType: ResponseType.bytes,
          // sendTimeout: Duration(seconds: 5),
          // receiveTimeout: Duration(seconds: 3),
          followRedirects: false,
          maxRedirects: 0,
          validateStatus: (status) => status! < 500,
        ),
      );
      switch (loginResponse.statusCode) {
        case 200:
          {
            // loginResponseHtml 即为把 login 信息 POST 后返回的结果（HTML），返回的内容编码为 GBK
            String loginResponseHtml = gbk.decode(loginResponse.data);
            String errorInfo = await getErrorInfoFromHtml(loginResponseHtml);
            return [LoginResponseStatus.failed, errorInfo];
          }
        //被重定向
        case 302:
          {
            String redirectUrl = loginResponse.headers['Location']![0];
            if (kDebugMode) {
              print(redirectUrl);
            }

            List returnList = [];
            await confirmLogin(cookie).then((List userInfo) {
              if (kDebugMode) {
                print(userInfo);
              }
              returnList = [
                LoginResponseStatus.success,
                userInfo[0],
                userInfo[1]
              ];
            }, onError: (Object error) {
              if (kDebugMode) {
                print(error);
              }
              returnList = [LoginResponseStatus.unknowError];
            });
            // 成功： 返回 [LoginResponseStatus.success, 姓名，学号]
            // 错误： 返回 [LoginResponseStatus.unknowError]
            return returnList;
          }
        default:
          {
            if (kDebugMode) {
              print(loginResponse.statusCode);
            }
            return [
              LoginResponseStatus.otherStatusCode,
              loginResponse.statusCode
            ];
          }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        String data = gbk.decode(e.response?.data);
        print("error : $data");
      }
      return [LoginResponseStatus.unknowError];
    }
  }

  // 从响应的 html 里获得错误信息
  Future<String> getErrorInfoFromHtml(dynamic inputHtml) async {
    var document = parse(inputHtml);

    // 下面两个写法得到的结果一样
    // var errorInfo =  document.getElementsByClassName("dlmi1")[0].getElementsByTagName("table")[0].getElementsByTagName("tbody")[0].getElementsByTagName("tr")[2].getElementsByTagName("td")[0].getElementsByTagName("font")[0].innerHtml;
    var errorInfo = document
        .getElementsByClassName("dlmi1")[0]
        .children[0]
        .children[0]
        .children[2]
        .children[0]
        .children[0]
        .innerHtml;

    debugPrint(errorInfo);
    return errorInfo;
  }

  // 从响应的 html 里获取姓名和学号
  Future<List> getNameAndStudentIDFromHtml(dynamic inputHtml) async {
    var document = parse(inputHtml);

    var nameElement = document.getElementsByClassName("block1text")[0].nodes[0];
    var nameValue =
        nameElement.toString().split('"')[1].trimLeft().split('：')[1];

    var studentIDElement =
        document.getElementsByClassName("block1text")[0].nodes[2];
    var studenIDValue =
        studentIDElement.toString().split('"')[1].trimLeft().split('：')[1];

    if (nameValue != '' && studenIDValue != '') {
      return [nameValue, studenIDValue];
    } else {
      return ['not found name', 'not found studenID'];
    }
  }
}
