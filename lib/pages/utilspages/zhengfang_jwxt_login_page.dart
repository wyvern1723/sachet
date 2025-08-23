import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/jwxt_type.dart';
import 'package:sachet/models/user.dart';
import 'package:sachet/providers/login_page_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_name.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/error_info_snackbar.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/logging_in_snackbar.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/login_successful_dialog.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/password_form_field.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/username_form_field.dart';
import 'package:provider/provider.dart';

class ZhengFangJwxtLoginPage extends StatelessWidget {
  const ZhengFangJwxtLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginPageProvider(),
      child: ZhengFangJwxtLoginPageView(),
    );
  }
}

class ZhengFangJwxtLoginPageView extends StatefulWidget {
  const ZhengFangJwxtLoginPageView({super.key});

  @override
  State<ZhengFangJwxtLoginPageView> createState() =>
      _ZhengFangJwxtLoginPageViewState();
}

class _ZhengFangJwxtLoginPageViewState
    extends State<ZhengFangJwxtLoginPageView> {
  final _loginFormKey = GlobalKey<FormState>();
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  String? showErrorText;

  /// 获取储存的 学号和密码
  Future loadDataFromSecureStorage() async {
    String? studentIDText =
        context.read<ZhengFangUserProvider>().user.studentID;
    String? passwordText = await ZhengFangUserProvider.readPassword();
    usernameTextController.text = studentIDText ?? '';
    passwordTextController.text = passwordText ?? '';

    // 如果存在保存的数据，更改 是否记住 的状态 = true
    if (passwordText != null) {
      context
          .read<LoginPageProvider>()
          .setIsRememberPassword(true, JwxtType.zhengfang);
    }
  }

  Future _pressLoginButton(BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      context.read<LoginPageProvider>().setIsLoggingIn(true);
      final messenger = ScaffoldMessenger.of(context);
      // 显示正在登录 SnackBar
      messenger.showSnackBar(loggingInSnackBar(context));
      ZhengFangLoginService zhengFangLoginService = ZhengFangLoginService();

      try {
        // 尝试登录
        await zhengFangLoginService.login(
          username: usernameTextController.text,
          password: passwordTextController.text,
        );

        // *****无异常*****
        // 保存用户信息
        String cookie = zhengFangLoginService.cookie;
        String name = '';
        try {
          name = await getNameZF(cookie);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        User user = User(
          cookie: cookie,
          name: name,
          studentID: usernameTextController.text,
        );
        await context.read<ZhengFangUserProvider>().setUser(user);
        // 如果选择记住密码，储存至 secureStorage
        if (context.read<LoginPageProvider>().isRememberPassword == true) {
          await ZhengFangUserProvider.savePassword(passwordTextController.text);
        }
        // 隐藏正在登录 SnackBar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // 显示登录成功 Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              LoginSuccessfulDialog(userName: name),
        );
      } catch (e) {
        // *****有异常*****
        // 隐藏正在登录 SnackBar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // 显示 显示登录错误信息的 SnackBar，显示3秒后隐藏
        ScaffoldMessenger.of(context).showSnackBar(errorInfoSnackBar(
            context, e.toString().replaceAll('Exception: ', '')));
        await Future.delayed(const Duration(seconds: 3));
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      context.read<LoginPageProvider>().setIsLoggingIn(false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadDataFromSecureStorage();
  }

  @override
  void dispose() {
    usernameTextController.dispose();
    passwordTextController.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MaterialBanner(
                forceActionsBelow: true,
                content: Text('若您是使用初始密码首次登录，请先在浏览器登录教务系统后设置新密码'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: Text('在浏览器打开教务系统'),
                    onPressed: () {
                      openLink(newJwxtBaseUrl);
                    },
                  ),
                ],
                padding: EdgeInsetsDirectional.only(
                  start: 16.0,
                  top: 8.0,
                  end: 16.0,
                  bottom: 0.0,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.login_outlined,
                    size: 44,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text('登录到新教务系统',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text('(正方教务系统)',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              const SizedBox(height: 32),

              // 学号输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: UsernameFormField(controller: usernameTextController),
              ),

              const SizedBox(height: 12),

              // 密码输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: PasswordFormField(controller: passwordTextController),
              ),

              const SizedBox(height: 12),

              // 记住密码
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Selector<LoginPageProvider, bool>(
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
                                        value, JwxtType.zhengfang);
                              }
                            },
                            semanticLabel: '记住密码',
                          ),
                          Text('记住密码'),
                        ],
                      );
                    }),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Selector<LoginPageProvider, bool>(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
