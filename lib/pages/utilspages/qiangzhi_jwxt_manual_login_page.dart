import 'package:flutter/material.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/user.dart';
import 'package:sachet/providers/qiangzhi_user_provider.dart';
import 'package:sachet/services/qiangzhi_jwxt/login/qiangzhi_login_service.dart';
import 'package:sachet/widgets/utilspages_widgets/manual_login_page_widgets/manual_login_successful_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class ManualLoginPage extends StatefulWidget {
  const ManualLoginPage({super.key, required this.initialUrl});
  final String initialUrl;

  @override
  State<ManualLoginPage> createState() => _ManualLoginPageState();
}

class _ManualLoginPageState extends State<ManualLoginPage> {
  final CookieManager _cookieManager = CookieManager.instance();
  InAppWebViewController? _webViewController;

  @override
  void dispose() {
    InAppWebViewController.clearAllCache();
    super.dispose();
  }

  void getLoginCookie() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('检查登录状态'),
        content: Column(
          children: [CircularProgressIndicator()],
        ),
      ),
    );
  }

  /// 检查是否登录成功（二次检查）
  Future checkLogin({
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
      var cookie = await getCookie(url, controller);
      debugPrint(cookie);
      List userInfo = [];
      await QiangZhiLoginService().confirmLogin(cookie).then(
          (List result) async {
        userInfo = result;

        // 写入 User 信息
        User user = User(
          cookie: cookie,
          name: userInfo[0],
          studentID: userInfo[1],
        );
        await context.read<QiangZhiUserProvider>().setUser(user);

        // 显示获取登录信息成功的 Dialog
        showDialog(
          context: context,
          builder: (context) => ManualLoginSuccessfulDialog(
            userName: userInfo[0],
            cookie: cookie,
          ),
        );
      }, onError: (Object error) {
        debugPrint(error.toString());
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
      });
    }
  }

  /// 获取 cookie
  ///
  /// return [cookie] (JSESSIONID=xxxxxx)
  Future<String> getCookie(
    String url,
    InAppWebViewController controller,
  ) async {
    List<Cookie> cookies = await _cookieManager.getCookies(
      url: WebUri(url),
      webViewController: controller,
    );
    String responseCookie = '';
    cookies.forEach((cookie) {
      // Cookie{domain: jwxt.xtu.edu.cn, expiresDate: null, isHttpOnly: true, isSecure: false, isSessionOnly: null, name: JSESSIONID, path: /, sameSite: null, value: 18488E62810E04D200293C0963D36187}
      responseCookie = '${cookie.name}=${cookie.value}';
    });
    return responseCookie;
  }

  @override
  Widget build(BuildContext context) {
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
                    '2. 在 业务直通车 点击 「教务系统」 ，跳转到教务系统主页\n'
                    '3. 等待自动弹出登录成功弹窗，如未弹出请点击「已完成登录」')
                : Text('登录完成进入主页后会自动弹出登录成功弹窗，如未弹出请点击「已完成登录」'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                child: Text('已完成登录'),
                onPressed: () {
                  checkLogin(
                      url: jwxtBaseUrlHttps, controller: _webViewController);
                },
              ),
            ],
            padding: EdgeInsetsDirectional.only(
                start: 16.0, top: 16.0, end: 16.0, bottom: 4.0),
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

                // 如果当前页面的 url 是教务系统主页，说明登录成功
                if (url?.rawValue == jwxtMainPageUrl ||
                    url?.rawValue == jwxtMainPageUrlHttps) {
                  debugPrint('重定向至 $jwxtMainPageUrl，登录成功');
                  checkLogin(
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
