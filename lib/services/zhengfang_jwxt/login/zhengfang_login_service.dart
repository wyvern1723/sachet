import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:sachet/services/zhengfang_jwxt/login/encrypt.dart';

class ZhengFangLoginService {
  final Dio _dio;
  ZhengFangLoginService()
      : _dio = Dio(BaseOptions(validateStatus: (_) => true));

  String _cookie = '';
  String _route = '';
  String _csrftoken = '';
  String get cookie => _cookie;

  Future login({
    required String username, // 用户名（学号）
    required String password,
  }) async {
    // 01. 初始化请求，获取 cookie 和 csrftoken
    await _firstContact();

    // 02. 从服务器获取公钥
    final publicKey = await _fetchPublicKey();

    // 03. 对用户输入的密码用从服务器获取的公钥执行加密
    final encryptedPassword = RSAEncryptor.encryptPassword(
        password, publicKey['modulus']!, publicKey['exponent']!);

    // 04. 发起登录 POST 请求
    await _loginRequest(
      csrftoken: _csrftoken,
      yhm: username,
      mm: encryptedPassword,
    );
  }

  /// 初始化请求，获取 cookie 和 csrftoken
  Future _firstContact() async {
    try {
      final response = await _dio.get('https://jw.xtu.edu.cn/jwglxt/xtgl/');

      if (response.statusCode != 200) {
        throw 'Http status code = ${response.statusCode}';
      }

      var csrftoken = _extractCsrfToken(response.data);
      if (csrftoken == null) {
        throw 'csrftoken is null';
      }
      _csrftoken = csrftoken;

      // 提取 cookie
      // Set-Cookie: JSESSIONID=C56AC3386AB38D0B4383793ED3FBD8B4; Path=/jwglxt; HttpOnly
      // Set-Cookie: route=624c331127ba41d300f8ee425af31cc1; Path=/
      final List<String>? setCookies = response.headers['Set-Cookie'];
      if (setCookies == null || setCookies.isEmpty) {
        throw '响应中未包含 Set-Cookie';
      }
      /*
      final String jsessionid = cookies[0].toString().split(';')[0];
      final String route = cookies[1].toString().split(';')[0];
      */
      String? jsessionid;
      String? route;
      for (final setCookie in setCookies) {
        final parts = setCookie.split(';');
        if (parts.isEmpty) continue;

        final cookieValue = parts[0].trim();
        if (cookieValue.startsWith('JSESSIONID=')) {
          jsessionid = cookieValue;
        } else if (cookieValue.startsWith('route=')) {
          route = cookieValue;
        }
      }
      if (jsessionid == null) {
        throw '无法从 Set-Cookie 中提取 JSESSIONID';
      }
      if (route == null) {
        throw '无法从 Set-Cookie 中提取route';
      }
      _cookie = '$jsessionid; $route';
      _route = route;
    } on DioException catch (e) {
      throw Exception('初始化网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('初始化请求失败: $e');
    }
  }

  /// 从 HTML 中提取 csrftoken
  String? _extractCsrfToken(String html) {
    final document = parse(encoding: '', html);
    String? csrftoken =
        document.getElementById('csrftoken')!.attributes['value'];
    return csrftoken;
  }

  /// 从服务器获取 rsa 公钥
  Future _fetchPublicKey() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    try {
      Response response = await _dio.get(
        'https://jw.xtu.edu.cn/jwglxt/xtgl/login_getPublicKey.html',
        queryParameters: {
          'time': timestamp,
          // '_': timestamp - 700,
        },
        options: Options(headers: {
          'Host': 'jw.xtu.edu.cn',
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
          'Accept': 'application/json, text/javascript, */*; q=0.01',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate, br, zstd',
          'X-Requested-With': 'XMLHttpRequest',
          'Connection': 'keep-alive',
          'Referer': 'https://jw.xtu.edu.cn/jwglxt/xtgl/login_slogin.html',
          'Cookie': _cookie,
          'Upgrade-Insecure-Requests': '1',
          'Pragma': 'no-cache',
          'Cache-Control': 'no-cache',
        }),
      );
      if (response.statusCode != 200) {
        throw 'Http status code = ${response.statusCode}';
      }

      // 正确返回的JSON格式为: {"modulus": "...", "exponent": "..."}
      if (response.data is! Map) {
        throw '格式无效';
      }

      String? modulus = response.data['modulus'];
      String? exponent = response.data['exponent'];
      if (modulus == null || exponent == null) {
        throw '格式错误';
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception('获取公钥网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取公钥失败: $e');
    }
  }

  /// 发起登录 POST 请求
  Future _loginRequest({
    required String csrftoken,
    required String yhm, // 用户名
    required String mm,
  }) async {
    try {
      final response = await _dio.post(
        'https://jw.xtu.edu.cn/jwglxt/xtgl/login_slogin.html',
        data: {
          'csrftoken': csrftoken,
          'language': 'zh_CN',
          'ydType': '',
          'yhm': yhm,
          'mm': [mm, mm]
        },
        options: Options(headers: {
          'Host': 'jw.xtu.edu.cn',
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate, br, zstd',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Origin': 'https://jw.xtu.edu.cn',
          'Connection': 'keep-alive',
          'Referer': 'https://jw.xtu.edu.cn/jwglxt/xtgl/login_slogin.html',
          'Cookie': _cookie,
          'Upgrade-Insecure-Requests': '1',
          'Priority': 'u=0, i',
          'Pragma': 'no-cache',
          'Cache-Control': 'no-cache',
        }),
      );
      if (response.statusCode == 200) {
        String? errorMessage = _extractErrorMessage(response.data);
        if (errorMessage == null || errorMessage == '') {
          throw '登录失败';
        }
        throw '登录失败: $errorMessage';
      }

      if (response.statusCode != 302) {
        throw 'Http status code = ${response.statusCode}';
      }

      // print('status code == 302,登录成功！');

      // var location = response.headers['Location']![0];
      // print('location: $location');
      // var realUri = response.realUri;
      // print('realUri: $realUri');

      // 提取 cookie
      // Set-Cookie: rememberMe=deleteMe; Path=/jwglxt; Max-Age=0; Expires=Mon, 18-Aug-2025 08:38:03 GMT; SameSite=lax
      // Set-Cookie: JSESSIONID=238E9E150DE4E48734521F02EF33D366; Path=/jwglxt; HttpOnly
      final List<String>? setCookies = response.headers['Set-Cookie'];
      if (setCookies == null || setCookies.isEmpty) {
        throw '响应中未包含 Set-Cookie';
      }

      // final String jsessionid = cookies[1].toString().split(';')[0];
      String? jsessionid;
      for (final setCookie in setCookies) {
        final parts = setCookie.split(';');
        if (parts.isEmpty) continue;

        final cookieValue = parts[0].trim();
        if (cookieValue.startsWith('JSESSIONID=')) {
          jsessionid = cookieValue;
          break;
        }
      }
      if (jsessionid == null) {
        throw '无法从 Set-Cookie 中提取 JSESSIONID';
      }
      _cookie = '$jsessionid; $_route';
    } on DioException catch (e) {
      throw Exception('登录 POST 网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('登录 POST 失败: $e');
    }
  }

  /// 从 html 提取显示的错误信息（e.g. "用户名或密码不正确，请重新输入！"）
  String? _extractErrorMessage(String html) {
    var document = parse(encoding: '', html);
    final element = document.getElementById('tips');
    if (element == null) {
      return null;
    }

    final String result = element.text.trim();
    return result;
  }
}
