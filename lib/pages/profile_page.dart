import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/about_page.dart';
import 'package:sachet/pages/settings_page.dart';
import 'package:sachet/pages/utilspages/qiangzhi_jwxt_login_page.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
import 'package:sachet/providers/qiangzhi_user_provider.dart';
import 'package:sachet/utils/utils_funtions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        context.read<ScreenNavProvider>().setCurrentPageToStartupPage();
      },
      child: Scaffold(
        appBar: AppBar(title: Text('我')),
        body: ListView(
          children: [
            // 强智教务系统
            Selector<QiangZhiUserProvider, ({String name, String id})>(
              selector: (_, qiangzhiUserProvider) => (
                name: qiangzhiUserProvider.user.name ?? '未登录',
                id: qiangzhiUserProvider.user.studentID ?? '点击登录'
              ),
              builder: (_, data, __) {
                return ListTile(
                    leading: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.account_circle),
                    ),
                    title: Text(data.name),
                    subtitle: Text(data.id),
                    trailing: IconButton(
                      onPressed: () async {
                        await showLogoutDialog(context, JwxtType.qiangzhi);
                      },
                      tooltip: '退出登录',
                      icon: Icon(Icons.logout_outlined),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const QiangZhiJwxtLoginPage();
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
      ),
    );
  }
}
