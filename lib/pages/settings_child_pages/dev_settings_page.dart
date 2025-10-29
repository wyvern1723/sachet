import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/intro_screen/intro_screen.dart';
import 'package:sachet/pages/settings_child_pages/cached_data_listview_page.dart';
import 'package:sachet/pages/settings_child_pages/class_schedule_data_listview_page.dart';
import 'package:sachet/pages/settings_child_pages/course_color_data_listview_page.dart';
import 'package:sachet/pages/settings_child_pages/other_data_listview_page.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/widgets/settingspage_widgets/settings_section_title.dart';

class DevSettingsPage extends StatelessWidget {
  const DevSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isEnableDevMode = context.select<SettingsProvider, bool>(
        (settingsProvider) => settingsProvider.isEnableDevMode);
    return Scaffold(
      appBar: AppBar(
        title: const Text("开发者设置"),
      ),
      body: ListView(
        children: [
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                tileColor: isEnableDevMode
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surfaceDim,
                title: const Text('启用开发者模式'),
                trailing: Switch(
                  value: isEnableDevMode,
                  onChanged: (value) {
                    if (isEnableDevMode) {
                      context.read<SettingsProvider>().disableDevMode();
                    } else {
                      context.read<SettingsProvider>().enableDevMode();
                    }
                  },
                ),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: SettingsSectionTitle(
              title: '应用设置',
              iconData: Icons.app_settings_alt,
            ),
          ),
          ListTile(
            enabled: isEnableDevMode,
            leading: const Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.storage_outlined),
            ),
            title: const Text('缓存数据'),
            subtitle: const Text('培养方案、考试时间'),
            onTap: () {
              Navigator.of(context)
                  .push(fadeTransitionPageRoute(CachedDataListviewPage()));
            },
          ),
          ListTile(
            enabled: isEnableDevMode,
            leading: const Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.calendar_month_outlined),
            ),
            title: const Text('课表数据'),
            subtitle: const Text('课程表数据'),
            onTap: () {
              Navigator.of(context).push(
                  fadeTransitionPageRoute(ClassScheduleDataListviewPage()));
            },
          ),
          ListTile(
            enabled: isEnableDevMode,
            leading: const Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.palette_outlined),
            ),
            title: const Text('课程颜色数据'),
            subtitle: const Text('课程名称和对应颜色'),
            onTap: () {
              Navigator.of(context)
                  .push(fadeTransitionPageRoute(CourseColorDataListviewPage()));
            },
          ),
          if (Platform.isAndroid)
            ListTile(
              enabled: isEnableDevMode,
              leading: const Align(
                widthFactor: 1,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.settings_applications_outlined),
              ),
              title: const Text('其他数据'),
              subtitle: const Text('SharedPreferences、SecureStorage...'),
              onTap: () {
                Navigator.of(context)
                    .push(fadeTransitionPageRoute(OtherMiscDataListviewPage()));
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: SettingsSectionTitle(
              title: '关于我们',
              iconData: Icons.help_outline,
            ),
          ),
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.question_mark_outlined),
            ),
            title: const Text('Q&A'),
            subtitle: Text('疑难解答'),
          ),
          if (kDebugMode)
            ListTile(
              leading: Align(
                widthFactor: 1,
                alignment: Alignment.centerLeft,
                child: const Icon(Icons.build_circle),
              ),
              title: const Text('太棒了，您正处于调试模式！'),
              subtitle: Text('Generating More Bugs...'),
            ),
          ListTile(
            title: Text('Intro Screen'),
            leading: Icon(Icons.cruelty_free),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => IntroScreen()),
                (Route route) => false,
              );
            },
          )
        ],
      ),
    );
  }
}
