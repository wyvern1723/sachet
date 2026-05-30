import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/intro_screen/intro_screen.dart';
import 'package:sachet/pages/settings_child_pages/cached_data_listview_page.dart';
import 'package:sachet/pages/settings_child_pages/class_schedule_data_listview_page.dart';
import 'package:sachet/pages/settings_child_pages/course_color_data_listview_page.dart';
import 'package:sachet/pages/settings_child_pages/other_data_listview_page.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/utils_functions.dart';
import 'package:sachet/widgets/settingspage_widgets/settings_section_title.dart';

class DevSettingsPage extends StatelessWidget {
  const DevSettingsPage({super.key});

  void _showCookieInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.cookie),
        title: Text('Cookie'),
        content: SelectionArea(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: ZhengFangUserProvider.cookie),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: IconButton(
                    onPressed: () =>
                        copyToClipboard(context, ZhengFangUserProvider.cookie),
                    icon: const Icon(Icons.content_copy),
                    iconSize: 14,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    splashRadius: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 16, 20, 4),
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭'),
          )
        ],
      ),
    );
  }

  void _showDeviceInfoDialog(BuildContext context) {
    // 屏幕信息
    final view = ui.PlatformDispatcher.instance.views.first;
    final physicalSize = view.physicalSize;
    final dpr = view.devicePixelRatio;
    final logicalSize =
        Size(physicalSize.width / dpr, physicalSize.height / dpr);

    // 平台信息
    final bool isWeb = kIsWeb;
    final String osName = isWeb ? 'Web (Browser)' : Platform.operatingSystem;
    final String osVersion = isWeb ? 'HTML5' : Platform.operatingSystemVersion;
    final String localName = isWeb ? 'Web Locale' : Platform.localeName;

    final String dartVersion = Platform.version;

    // 运行模式
    final String runMode =
        kDebugMode ? 'Debug 🐛' : (kReleaseMode ? 'Release 🚀' : 'Profile 📊');

    final String copyText = '''
[设备与环境信息]
运行模式: $runMode
操作系统: $osName
系统版本: $osVersion
------------------
Dart 版本: $dartVersion
物理分辨率: ${physicalSize.width} × ${physicalSize.height}
逻辑分辨率: ${logicalSize.width.toStringAsFixed(2)} × ${logicalSize.height.toStringAsFixed(2)}
像素比(DPR): ${dpr.toString()}
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.terminal, size: 32, color: Colors.blueGrey),
        title: const Text('设备与环境信息'),
        content: SingleChildScrollView(
          child: SelectionArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, '运行模式', runMode),
                _buildInfoRow(context, '操作系统', osName),
                _buildInfoRow(context, '系统版本', osVersion),
                _buildInfoRow(context, '区域语言', localName),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1),
                ),
                _buildInfoRow(context, 'Dart 版本', dartVersion),
                _buildInfoRow(context, '物理分辨率',
                    '${physicalSize.width} × ${physicalSize.height}'),
                _buildInfoRow(context, '逻辑分辨率',
                    '${logicalSize.width.toStringAsFixed(2)} × ${logicalSize.height.toStringAsFixed(2)}'),
                _buildInfoRow(context, '像素比(DPR)', dpr.toString()),
              ],
            ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.copy_all, size: 18),
            label: const Text('复制全部'),
            onPressed: () {
              copyToClipboard(context, copyText);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

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
              title: '信息查看',
              iconData: Icons.perm_device_information,
            ),
          ),
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.cookie_outlined),
            ),
            title: const Text('Cookie'),
            subtitle: const Text('当前登录到正方教务系统的 Cookie'),
            onTap: () => _showCookieInfoDialog(context),
          ),
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.terminal),
            ),
            title: const Text('设备与环境信息'),
            onTap: () => _showDeviceInfoDialog(context),
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
