import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/utils/auto_check_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appVersion = '';
  String appBuildNumber = '';

  /// 上一次 Tap 时间
  DateTime? _lastTapTime;

  /// 有效 Tap 次数
  int _tapCount = 0;
  late bool _isDeveloperModeEnabled;

  void _hitDev() {
    Duration twoTapDuration =
        DateTime.now().difference(_lastTapTime ??= DateTime.now());
    // 如果间隔时间 < 500ms，记为有效 Tap => _tapCount++（如果是第一次 Tap，也记为有效 Tap）
    if (twoTapDuration < Duration(milliseconds: 500)) {
      _tapCount++;
    } else {
      // 间隔时间 >= 500ms，间隔过长，重置 _tapCount = 1
      _tapCount = 1;
    }
    _lastTapTime = DateTime.now();
    if (_tapCount == 7) {
      _tapCount = 0;
      if (_isDeveloperModeEnabled == false) {
        _isDeveloperModeEnabled = true;
        context.read<SettingsProvider>().enableDevMode();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('开发者模式已启用'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('您已处于开发者模式'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }
  }

  Future getAppVersion() async {
    // 获取 App 当前版本
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      appBuildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    getAppVersion();
    _isDeveloperModeEnabled = context.read<SettingsProvider>().isEnableDevMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.fill,
                  cacheWidth:
                      (88 * MediaQuery.of(context).devicePixelRatio).round(),
                  cacheHeight:
                      (88 * MediaQuery.of(context).devicePixelRatio).round(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sachet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于应用'),
            onTap: () => showAboutDialog(
              applicationName: 'Sachet',
              applicationVersion: appVersion,
              applicationIcon: SizedBox(
                width: 74,
                height: 94,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      fit: BoxFit.fill,
                      width: 70,
                      height: 70,
                      cacheWidth: (70 * MediaQuery.of(context).devicePixelRatio)
                          .round(),
                      cacheHeight:
                          (70 * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                    ),
                  ),
                ),
              ),
              applicationLegalese: '©2025 Wyvern1723',
              children: [
                const Text(
                    "Sachet is a FREE software published under MIT License and comes with ABSOLUTELY NO WARRANTY.")
              ],
              context: context,
            ),
          ),
          ListTile(
            leading: const Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.person),
            ),
            title: const Text('开发者'),
            subtitle: const Text('Wyvern1723'),
            onTap: () => openLink(appDeveloperProfileUrl),
          ),
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.link),
            ),
            title: Text('源代码'),
            subtitle: Text(appRepoUrl),
            onTap: () => openLink(appRepoUrl),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: appRepoUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("链接已复制到剪贴板")),
              );
            },
          ),
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.android),
            ),
            title: Text('当前版本'),
            trailing: TextButton(
                onPressed: () async {
                  await checkUpdate(isShowDetails: true);
                },
                child: Text('检查更新')),
            subtitle: Text('v$appVersion ($appBuildNumber)  $abi'),
            onTap: () {
              _hitDev();
            },
          ),
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.get_app),
            ),
            title: Text('最新版下载'),
            subtitle: Text(appReleaseUrl),
            onTap: () => openLink(appReleaseUrl),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: appReleaseUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("链接已复制到剪贴板")),
              );
            },
          ),
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.email),
            ),
            title: Text('反馈'),
            subtitle: Text('wyvern1723@outlook.com'),
            onTap: () => launchUrl(Uri.parse("mailto:wyvern1723@outlook.com")),
            onLongPress: () {
              Clipboard.setData(
                  ClipboardData(text: "mailto:wyvern1723@outlook.com"));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("链接已复制到剪贴板")),
              );
            },
          ),
        ],
      ),
    );
  }
}
