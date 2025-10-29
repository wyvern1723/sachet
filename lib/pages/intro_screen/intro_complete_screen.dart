import 'package:flutter/material.dart';
import 'package:sachet/models/nav_type.dart';
import 'package:sachet/pages/utilspages/zhengfang_jwxt_login_page.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/app_global.dart';

class IntroCompleteScreen extends StatefulWidget {
  /// 引导完成，询问是否要登录到教务系统
  const IntroCompleteScreen({super.key});

  @override
  State<IntroCompleteScreen> createState() => _IntroCompleteScreenState();
}

class _IntroCompleteScreenState extends State<IntroCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          16.0,
          AppBar().preferredSize.height +
              MediaQuery.of(context).viewPadding.top,
          16.0,
          0.0,
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      // Icons.rocket_launch,
                      // Icons.sports_martial_arts_outlined,
                      Icons.auto_awesome_outlined,
                      // Icons.auto_fix_high_outlined,
                      // Icons.auto_fix_normal_outlined,
                      // Icons.check_box_outlined,
                      // Icons.golf_course_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '设置完成！',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          '已经完成了应用基本设置。\n需要现在登录到教务系统吗？',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          SettingsProvider.navigationType ==
                                  NavType.navigationDrawer.type
                              ? AppGlobal.appSettings.startupPage ?? '/class'
                              : '/navBarView',
                          (Route route) => false,
                        );
                      },
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                          ..pushNamedAndRemoveUntil(
                            SettingsProvider.navigationType ==
                                    NavType.navigationDrawer.type
                                ? AppGlobal.appSettings.startupPage ?? '/class'
                                : '/navBarView',
                            (Route route) => false,
                          )
                          ..push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const ZhengFangJwxtLoginPage();
                              },
                            ),
                          );
                      },
                      child: Text('去登录'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
