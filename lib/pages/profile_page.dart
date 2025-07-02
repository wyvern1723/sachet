import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/about_page.dart';
import 'package:sachet/pages/settings_page.dart';
import 'package:sachet/pages/utilspages/login_page.dart';
import 'package:sachet/provider/user_provider.dart';
import 'package:sachet/utils/services/path_provider_service.dart';
import 'package:sachet/widgets/settingspage_widgets/logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      appBar: AppBar(title: Text('我')),
      body: ListView(
        children: [
          Selector<UserProvider, ({String name, String id})>(
            selector: (_, userProvider) => (
              name: userProvider.user.name ?? '未登录',
              id: userProvider.user.studentID ?? '点击登录'
            ),
            builder: (_, data, __) {
              return ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text(data.name),
                  subtitle: Text(data.id),
                  trailing: IconButton(
                      onPressed: () async {
                        await showLogoutDialog();
                      },
                      tooltip: '退出登录',
                      icon: Icon(Icons.logout_outlined)),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const LoginPage();
                        },
                      ),
                    );
                  });
            },
          ),
          ListTile(
            title: Text('设置'),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const SettingsPage();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text('关于'),
            leading: Icon(Icons.info),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const AboutPage();
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
