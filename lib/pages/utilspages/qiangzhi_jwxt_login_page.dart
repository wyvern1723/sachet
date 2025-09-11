import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/jwxt_type.dart';
import 'package:sachet/models/login_response_status.dart';
import 'package:sachet/models/user.dart';
import 'package:sachet/providers/login_page_provider.dart';
import 'package:sachet/services/qiangzhi_jwxt/login/captcha_recognizer.dart';
import 'package:sachet/services/qiangzhi_jwxt/login/qiangzhi_login_service.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/qiangzhi_user_provider.dart';
import 'package:sachet/pages/utilspages/qiangzhi_jwxt_manual_login_page.dart';
import 'package:sachet/utils/transform.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/error_info_snackbar.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/load_captcha_img_error_widget.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/logging_in_snackbar.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/login_successful_dialog.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/password_form_field.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/log_in_use_cookie_dialog.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/use_cookie_login_successful_dialog.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/username_form_field.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/verifycode_form_field.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/need_to_reset_password_dialog.dart';
import 'package:provider/provider.dart';

class QiangZhiJwxtLoginPage extends StatelessWidget {
  const QiangZhiJwxtLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginPageProvider(),
      child: QiangZhiJwxtLoginPageView(),
    );
  }
}

class QiangZhiJwxtLoginPageView extends StatefulWidget {
  const QiangZhiJwxtLoginPageView({super.key});

  @override
  State<QiangZhiJwxtLoginPageView> createState() =>
      _QiangZhiJwxtLoginPageViewState();
}

class _QiangZhiJwxtLoginPageViewState extends State<QiangZhiJwxtLoginPageView> {
  final _loginFormKey = GlobalKey<FormState>();
  final usernameTextController = TextEditingController();
  final verifycodeTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  CaptchaRecognizer? _captchaRecognizer;

  Future<Uint8List>? getVerifyCodeImgFuture;
  String? showErrorText;
  String? _cookie;

  /// 获取储存的 学号和密码
  Future loadDataFromSecureStorage() async {
    String? studentIDText = context.read<QiangZhiUserProvider>().user.studentID;
    String? passwordText = await QiangZhiUserProvider.readPassword();
    usernameTextController.text = studentIDText ?? '';
    passwordTextController.text = passwordText ?? '';

    // 如果存在保存的数据，更改 是否记住 的状态 = true
    if (passwordText != null) {
      context
          .read<LoginPageProvider>()
          .setIsRememberPassword(true, JwxtType.qiangzhi);
    }
  }

  Future<Uint8List> getVerifyCodeImg() async {
    String cookie = await QiangZhiLoginService().getCookie();
    _cookie = cookie;
    if (kDebugMode) {
      setState(() {});
    }
    Uint8List verifyCodeImgBytes =
        await QiangZhiLoginService().getVerifyCodeImg(cookie);
    return verifyCodeImgBytes;
  }

  Future _pressLoginButton(BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      // 设置登录状态为正在登录
      context.read<LoginPageProvider>().setIsLoggingIn(true);

      // 显示正在登录 SnackBar
      ScaffoldMessenger.of(context).showSnackBar(loggingInSnackBar(context));

      // 向服务器发送登录信息
      var loginResponseList = await QiangZhiLoginService().loginPost(
          usernameTextController.text,
          passwordTextController.text,
          verifycodeTextController.text,
          _cookie ?? '');

      switch (loginResponseList[0]) {
        case LoginResponseStatus.unknowError:
          {
            if (kDebugMode) {
              print('未知错误');
              print('LoginResponseStatus.unknowError');
              print(loginResponseList);
            }
            // 隐藏正在登录 SnackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // 显示 显示登录错误信息的 SnackBar
            ScaffoldMessenger.of(context)
                .showSnackBar(errorInfoSnackBar(context, '登录失败，未知错误'));
            await Future.delayed(const Duration(seconds: 2));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        case LoginResponseStatus.failed:
          {
            if (kDebugMode) {
              print('登录失败');
              print('LoginResponseStatus.failed');
              print(loginResponseList);
            }

            String errorText = loginResponseList[1];

            // 隐藏正在登录 SnackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // 显示 显示登录错误信息的 SnackBar
            ScaffoldMessenger.of(context)
                .showSnackBar(errorInfoSnackBar(context, errorText));
            await Future.delayed(const Duration(seconds: 2));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // 不仅是验证码错误、用户名或密码错误也需要刷新验证码图片
            verifycodeTextController.clear();
            setState(() {
              getVerifyCodeImgFuture = getVerifyCodeImg();
            });
          }
        case LoginResponseStatus.success:
          {
            if (kDebugMode) {
              print('登录成功');
              print('LoginResponseStatus.success');
              print(loginResponseList);
            }

            String name = loginResponseList[1];
            String studentID = loginResponseList[2];
            User user = User(
              cookie: _cookie,
              name: name,
              studentID: studentID,
            );
            debugPrint(user.toJson().toString());

            await context.read<QiangZhiUserProvider>().setUser(user);

            // 如果选择记住密码，储存至 secureStorage
            if (context.read<LoginPageProvider>().isRememberPassword == true) {
              await QiangZhiUserProvider.savePassword(
                  passwordTextController.text);
            }
            // 隐藏正在登录 SnackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // 显示登录成功 Dialog
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  LoginSuccessfulDialog(userName: name),
            );
          }
        case LoginResponseStatus.needResetPassword:
          {
            if (kDebugMode) {
              print('登录成功，但被重定向到非主页。可能是因为初次登录，需要重设密码');
              print('LoginResponseStatus.needResetPassword');
              print(loginResponseList);
            }
            // 隐藏正在登录 SnackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            showDialog(
              context: context,
              builder: (BuildContext context) => NeedToResetPasswordDialog(),
            );
          }
        case LoginResponseStatus.otherStatusCode:
          {
            if (kDebugMode) {
              print('错误，得到其他 statuCode');
              print('statuCode: ${loginResponseList[1]}');
              print('LoginResponseStatus.otherStatusCode');
              print(loginResponseList);
            }
            // 隐藏正在登录 SnackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // 显示 显示登录错误信息的 SnackBar
            ScaffoldMessenger.of(context).showSnackBar(errorInfoSnackBar(
                context, '登录失败，statusCode: ${loginResponseList[1]}'));
            await Future.delayed(const Duration(seconds: 2));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
      }
      // 重置登录状态
      context.read<LoginPageProvider>().setIsLoggingIn(false);
    }
  }

  Future loginUseCookie(BuildContext context) async {
    String? cookie = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          LogInUseCookieDialog(jwxtType: JwxtType.qiangzhi),
    );
    if (cookie != null) {
      await QiangZhiLoginService().confirmLogin(cookie).then(
          (List userInfo) async {
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
          builder: (context) => UseCookieLoginSuccessfulDialog(
            userName: userInfo[0],
            cookie: cookie,
          ),
        );
      }, onError: (Object error) {
        debugPrint(error.toString());
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('登录失败'),
            content: Text('登录失败'),
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

  Future recognizeCaptchaImage(Uint8List imgBytes) async {
    try {
      String recognizedResult =
          await _captchaRecognizer!.recognizeCharsInImage(imgBytes);
      verifycodeTextController.text = recognizedResult;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    getVerifyCodeImgFuture = getVerifyCodeImg();
    super.initState();
    loadDataFromSecureStorage();
    _captchaRecognizer = CaptchaRecognizer();
  }

  @override
  void dispose() {
    if (_captchaRecognizer != null) {
      _captchaRecognizer!.dispose();
    }
    usernameTextController.dispose();
    passwordTextController.dispose();
    verifycodeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Form(
        key: _loginFormKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.login_outlined,
                    size: 44,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '登录到湘潭大学教务系统 (旧)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '(老教务系统仅限2024级及之前学生登录，2025级及之后无账号)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 32),

                // 学号输入框
                UsernameFormField(controller: usernameTextController),

                const SizedBox(height: 10),

                // 密码输入框
                PasswordFormField(controller: passwordTextController),

                const SizedBox(height: 10),

                // 图片验证码输入（左边输入框，右边验证码图片）
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      // 验证码输入框
                      child: VerifyCodeFormField(
                          controller: verifycodeTextController),
                    ),
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            getVerifyCodeImgFuture = getVerifyCodeImg();
                          });
                        },
                        child: FutureBuilder<Uint8List>(
                          future: getVerifyCodeImgFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                if (kDebugMode) {
                                  print(snapshot.error);
                                }
                                final error = snapshot.error;
                                if (error is DioException) {
                                  String? errorTypeText =
                                      dioExceptionTypeToText[error.type];
                                  return Center(
                                    child: LoadCaptchaImgErrorWidget(
                                      errorInfo:
                                          '验证码图片加载失败，${errorTypeText ?? ''}',
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: LoadCaptchaImgErrorWidget(
                                      errorInfo: '验证码图片加载失败，$error',
                                    ),
                                  );
                                }
                              } else if (snapshot.hasData) {
                                final Uint8List verifyCodeImgBytes =
                                    snapshot.data!;

                                // 加载 TFLite 模型，如果成功，开始识别；如果失败，无事发生……
                                if (SettingsProvider
                                    .isEnableCaptchaRecognizer) {
                                  _captchaRecognizer!.loadModel().then((_) {
                                    recognizeCaptchaImage(verifyCodeImgBytes);
                                  }, onError: (_) {});
                                }

                                return Center(
                                  child: Image(
                                    image: MemoryImage(verifyCodeImgBytes),
                                    // image: Image.memory(verifyCodeImgBytes).image,
                                  ),
                                );
                              } else {
                                return Center(
                                  child: LoadCaptchaImgErrorWidget(
                                    errorInfo: '验证码图片加载失败，无数据',
                                  ),
                                );
                              }
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                if (kDebugMode) SelectableText(_cookie ?? '_cookie is null'),

                // 记住密码
                Selector<LoginPageProvider, bool>(
                    selector: (_, loginPageProvider) =>
                        loginPageProvider.isRememberPassword,
                    builder: (_, isRememberPassword, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            visualDensity: VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.compact.vertical),
                            value: isRememberPassword,
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<LoginPageProvider>()
                                    .setIsRememberPassword(
                                        value, JwxtType.qiangzhi);
                              }
                            },
                            semanticLabel: '记住密码',
                          ),
                          Text('记住密码'),
                        ],
                      );
                    }),

                // 登录按钮
                Selector<LoginPageProvider, bool>(
                    selector: (_, loginPageProvider) =>
                        loginPageProvider.isLoggingIn,
                    builder: (_, isLoggingIn, __) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: isLoggingIn
                            ? null
                            : () async {
                                await _pressLoginButton(context);
                              },
                        child: const Text('登录'),
                      );
                    }),

                // 手动登录
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const QiangZhiManualLoginPage(
                                initialUrl: jwxtBaseUrlHttps,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('手动登录'),
                    ),
                  ],
                ),
                // 从信息门户登录
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const QiangZhiManualLoginPage(
                                initialUrl: xinXiMenHuBaseUrl,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('从信息门户登录'),
                    ),
                  ],
                ),

                // 使用 Cookie 登录
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await loginUseCookie(context);
                      },
                      label: const Text('使用 Cookie 登录'),
                      icon: const Icon(Icons.cookie),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
