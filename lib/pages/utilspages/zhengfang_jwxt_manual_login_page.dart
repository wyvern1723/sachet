import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/user.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_name.dart';
import 'package:sachet/widgets/utilspages_widgets/manual_login_page_widgets/manual_login_successful_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class ZhengFangManualLoginPage extends StatefulWidget {
  final String initialUrl;

  /// 手动登录正方教务系统
  const ZhengFangManualLoginPage({super.key, required this.initialUrl});

  @override
  State<ZhengFangManualLoginPage> createState() =>
      _ZhengFangManualLoginPageState();
}

class _ZhengFangManualLoginPageState extends State<ZhengFangManualLoginPage> {
  final CookieManager _cookieManager = CookieManager.instance();
  InAppWebViewController? _webViewController;

  @override
  void dispose() {
    InAppWebViewController.clearAllCache();
    super.dispose();
  }

  /// 检查是否登录成功
  Future checkLogin({
    required BuildContext context,
    required String url,
    required InAppWebViewController? controller,
  }) async {
    if (controller == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('登录不成功'),
          content: Text('登录不成功'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('确认'),
            )
          ],
        ),
      );
    } else {
      var cookie = await _getCookie(url, controller);
      try {
        final String name = await getNameZF(cookie);
        User user = User(
          cookie: cookie,
          name: name,
          // TODO: 获取学号
          studentID: '',
        );
        await context.read<ZhengFangUserProvider>().setUser(user);

        // 显示获取登录信息成功的 Dialog
        showDialog(
          context: context,
          builder: (context) => ManualLoginSuccessfulDialog(
            userName: name,
            cookie: cookie,
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('登录失败'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('确认'),
              )
            ],
          ),
        );
      }
    }
  }

  /// 获取 cookie
  ///
  /// return cookie (JSESSIONID=XXXX; route=xxxx)
  Future<String> _getCookie(
    String url,
    InAppWebViewController controller,
  ) async {
    // [Cookie{domain: jw.xtu.edu.cn, expiresDate: null, isHttpOnly: true, isSecure: false, isSessionOnly: null, name: JSESSIONID, path: /jwglxt, sameSite: null, value: E267D03E58C393ED52DD8E4EB733BE3B}, Cookie{domain: jw.xtu.edu.cn, expiresDate: null, isHttpOnly: false, isSecure: false, isSessionOnly: null, name: route, path: /, sameSite: null, value: 15ce7d662e775c91d3cd3dbdde8a10af}]
    List<Cookie> cookies = await _cookieManager.getCookies(
      url: WebUri(url),
      webViewController: controller,
    );

    String jsessionid = '';
    String route = '';
    for (var cookie in cookies) {
      if (cookie.name == 'JSESSIONID') {
        jsessionid = '${cookie.name}=${cookie.value}';
      } else if (cookie.name == 'route') {
        route = '${cookie.name}=${cookie.value}';
      }
    }

    return '$jsessionid; $route';
  }

  @override
  Widget build(BuildContext context) {
    PlatformInAppWebViewController.debugLoggingSettings.enabled = false;

    /// 是否是信息门户网页
    bool isXinXiMenHu = widget.initialUrl == xinXiMenHuBaseUrl;
    return Scaffold(
      appBar: AppBar(
        title: const Text('手动登录'),
      ),
      body: Column(
        children: [
          MaterialBanner(
            forceActionsBelow: true,
            content: isXinXiMenHu
                ? Text('1. 完成登录\n'
                    '2. 在 业务直通车 点击 「新教务系统」 ，跳转到新教务系统主页\n'
                    '3. 等待自动弹出登录成功弹窗，如未弹出请点击「已完成登录」')
                : Text('登录完成进入主页后会自动弹出登录成功弹窗，如未弹出请点击「已完成登录」'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                child: Text('已完成登录'),
                onPressed: () async {
                  await checkLogin(
                    context: context,
                    url: jwxtBaseUrlHttps,
                    controller: _webViewController,
                  );
                },
              ),
            ],
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 4.0),
          ),
          Expanded(
            child: InAppWebView(
              // key: webViewKey,
              // webViewEnvironment: webViewEnvironment,
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              // initialUserScripts: UnmodifiableListView<UserScript>([]),
              // initialSettings: settings,
              initialSettings: isXinXiMenHu
                  ? InAppWebViewSettings(
                      userAgent:
                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
                      preferredContentMode: UserPreferredContentMode.DESKTOP,
                      // enableViewportScale: true,
                      useHybridComposition: false)
                  : InAppWebViewSettings(useHybridComposition: false),
              // contextMenu: contextMenu,
              // pullToRefreshController: pullToRefreshController,
              onLoadStop: (controller, url) async {
                _webViewController = controller;

                // 如果是通过信息门户网页登录，才需要判断 url 是否是信息门户网页
                if (isXinXiMenHu) {
                  // 如果当前加载的是信息门户网页，进行额外处理
                  // 信息门户的网页如果只设置 User-Agent 为 桌面端 UA，还是不能合理布局，需要调整 'device-width'，比如 1000 左右来模拟电脑屏幕的大小，再设置合适的缩放(initial-scale < 1.0)
                  if (url?.rawValue == xinXiMenHuBaseUrl) {
                    String jsCode =
                        """document.querySelector('meta[name="viewport"]').setAttribute("content","width=1000, initial-scale=0.4, user-scalable=yes");""";
                    controller
                        .evaluateJavascript(source: jsCode)
                        .then((result) {
                      debugPrint(result);
                    });
                  }
                }

                // 登录成功
                if (url?.path == '/jwglxt/xtgl/lxtgl/index_initMenu.html') {
                  checkLogin(
                    context: context,
                    url: url!.rawValue,
                    controller: controller,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
