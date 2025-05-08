import 'package:flutter/material.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/provider/user_provider.dart';
import 'package:sachet/pages/settings_child_pages/dev_settings_page.dart';
import 'package:sachet/pages/settings_child_pages/theme_settings_page.dart';
import 'package:sachet/pages/settings_child_pages/advanced_settings_page.dart';
import 'package:sachet/pages/utilspages/login_page.dart';
import 'package:sachet/pages/settings_child_pages/customize_settings_page.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/services/path_provider_service.dart';
import 'package:sachet/widgets/settingspage_widgets/logout_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/startup_page_dropdownmenu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future showLogoutDialog() async {
    var result = await showDialog(
        context: context, builder: (BuildContext context) => LogoutDialog());
    if (result != null) {
      context.read<UserProvider>().deleteUser();
      final secureStorage = FlutterSecureStorage();
      secureStorage.deleteAll();
      // 如果返回 true,同时删除缓存数据
      if (result == true) {
        await CachedDataStorage().deleteAllCachedData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        // padding: const EdgeInsets.symmetric(
        //   vertical: 10,
        // ),

        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 20),
            child: Text(
              '账号设置',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Selector<UserProvider, bool>(
              selector: (_, userProvider) => userProvider.isLogin,
              builder: (_, isLogin, __) {
                return ListTile(
                  leading: const Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.login_outlined),
                  ),
                  title: Text('登录账号' + (isLogin == true ? '（重新登录）' : '')),
                  subtitle: Text('登录到教务系统'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const LoginPage();
                        },
                      ),
                    );
                  },
                );
              }),

          // ListTile(
          //   leading: const Align(
          //     widthFactor: 1,
          //     alignment: Alignment.centerLeft,
          //     child: Icon(Icons.switch_account_outlined),
          //   ),
          //   title: const Text('切换账号'),
          //   subtitle: const Text('切换到其他账号'),
          //   trailing: const Icon(Icons.arrow_forward),
          //   onTap: () {}
          // ),

          Selector<UserProvider, bool>(
              selector: (_, userProvider) => userProvider.isLogin,
              builder: (_, isLogin, __) {
                if (isLogin) {
                  return ListTile(
                    leading: const Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.logout_outlined),
                    ),
                    title: const Text('退出登录'),
                    subtitle: const Text('登出此账号，删除应用中关于此账号的记录'),
                    onTap: () async {
                      await showLogoutDialog();
                    },
                  );
                } else {
                  return SizedBox();
                }
              }),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 20),
            child: Text(
              '软件设置',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),

          // 主题设置
          ListTile(
            leading: const Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.palette),
            ),
            title: const Text('应用主题'),
            subtitle: const Text('改变应用的主题颜色'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const ThemeSettingsPage();
                  },
                ),
              );
            },
          ),

          // 外观设置
          ListTile(
            leading: const Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              // child: Icon(Icons.colorize_outlined),
              child: Icon(Icons.design_services_outlined),
            ),
            title: const Text('课表外观'),
            subtitle: const Text('定制课表外观'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const CustomizeSettingsPage();
                  },
                ),
              );
            },
          ),

          // 启动页设置
          const ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.toggle_on_outlined),
            ),
            title: Text('启动页'),
            subtitle: Text('设置应用启动时的首页'),
            trailing: StartupPageDropdownMenu(),
          ),

          // const SizedBox(height: 20),
          // Padding(
          //   padding: const EdgeInsets.only(left: 16, right: 16),
          //   child: Text(
          //     '高级设置',
          //     style: TextStyle(color: Theme.of(context).colorScheme.primary),
          //   ),
          // ),
          // const SizedBox(height: 20),

          // 高级设置
          ListTile(
            leading: const Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.miscellaneous_services_outlined),
            ),
            title: const Text('高级设置'),
            // subtitle: const Text('更多'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context)
                  .push(fadeTransitionPageRoute(AdvancedSettingsPage()));
            },
          ),
          // 开发者设置
          Selector<SettingsProvider, bool>(
              selector: (_, settingsProvider) =>
                  settingsProvider.isEnableDevMode,
              builder: (_, isEnableDevMode, __) {
                if (isEnableDevMode) {
                  return ListTile(
                    leading: const Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.developer_mode_outlined),
                    ),
                    title: const Text('开发者设置'),
                    subtitle: const Text('For nerds'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.of(context)
                          .push(fadeTransitionPageRoute(DevSettingsPage()));
                    },
                  );
                } else {
                  return SizedBox();
                }
              }),
        ],
      ),
    );
  }
}
