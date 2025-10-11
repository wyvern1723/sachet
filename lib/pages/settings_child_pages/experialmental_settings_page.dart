import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/settingspage_widgets/settings_section_title.dart';

import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

const NotificationDetails notificationDetailsTestChannel = NotificationDetails(
  android: AndroidNotificationDetails(
    'notification_test',
    '测试通知',
    channelDescription: '用于测试是否能成功通知',
    icon: "ic_notification",
    importance: Importance.max,
    priority: Priority.high,
  ),
);

class ExperialmentalSettingsPage extends StatefulWidget {
  const ExperialmentalSettingsPage({super.key});

  @override
  State<ExperialmentalSettingsPage> createState() =>
      _ExperialmentalSettingsPageState();
}

class _ExperialmentalSettingsPageState
    extends State<ExperialmentalSettingsPage> {
  /// 初始化 TZTimeZone
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Shanghai"));
  }

  /// 初始化 flutterLocalNotificationsPlugin
  Future _initializeNotifications() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
    );
  }

  /// 开启课程通知（上课提醒）
  Future _turnOnCourseNotification(BuildContext context) async {
    // 检查是否具有通知权限
    bool granted =
        await androidImplementation?.areNotificationsEnabled() ?? false;

    if (!granted) {
      // 申请通知权限
      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      if (!context.mounted) return;

      if (grantedNotificationPermission != true) {
        // 权限被拒绝，可能是用户在系统弹出的权限申请弹窗点击了「不允许」
        // 向用户解释没有这个权限无法提供通知，并提供「去授权」按钮
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('未授予通知权限'),
            content: Text('未授予通知权限，无法开启课程通知', style: TextStyle(fontSize: 16)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  _requestNotificationsPermission();
                  Navigator.of(context).pop();
                },
                child: const Text('去授权'),
              ),
            ],
          ),
        );

        // throw '未授予通知权限';
        return;
      }

      // 申请精确通知权限
      bool? grantedExactAlarmsPermission =
          await androidImplementation?.requestExactAlarmsPermission();

      if (!context.mounted) return;

      if (grantedExactAlarmsPermission != true) {
        // 权限被拒绝，可能是用户在系统弹出的权限申请弹窗点击了「不允许」，或是其他问题？（这个权限比较少见）
        // 向用户解释没有这个权限无法提供精确通知，但不授予也行，并提供「去授权」按钮
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('未授予精确通知权限'),
            content: Text(
              '未授予精确通知权限，将使用非精确通知，可能导致通知不会执行',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('不授权（使用非精确通知）'),
              ),
              TextButton(
                onPressed: () {
                  _requestExactAlarmsPermission();
                  Navigator.of(context).pop();
                },
                child: const Text('去授权'),
              ),
            ],
          ),
        );

        // throw '未授予精确通知权限';
        return;
      }
    }

    if (!context.mounted) return;

    // TODO: 设置通知

    // 将「启用课程通知」状态设为启用
    context.read<SettingsProvider>().setIsEnableCourseNotification(true);
  }

  Future<void> _turnOffCourseNotification(BuildContext context) async {
    // 取消所有 schedule 通知
    await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();

    if (!context.mounted) return;

    // 将「启用课程通知」状态设为关闭
    context.read<SettingsProvider>().setIsEnableCourseNotification(false);
  }

  /// 检查通知权限
  ///
  /// 成功: 弹出 "通知权限已启用" Dialog
  ///
  /// 失败: 弹出 "未授予通知权限，去授权" Dialog
  Future<void> _checkNotificationsPermission() async {
    final bool? areEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    if (!mounted) return;

    if (areEnabled == true) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('通知权限已启用', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确认'),
            ),
          ],
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('未授予通知权限', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: _requestNotificationsPermission,
              child: const Text('去授权'),
            ),
          ],
        ),
      );
    }
  }

  /// 检查精确通知权限
  ///
  /// 成功: 弹出 "精确通知权限已启用" Dialog
  ///
  /// 失败: 弹出 "未授予精确通知权限，去授权" Dialog
  Future<void> _checkExactAlarmsPermission() async {
    final bool? areEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.canScheduleExactNotifications();
    if (!mounted) return;

    if (areEnabled == true) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('精确通知权限已启用', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确认'),
            ),
          ],
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('未授予精确通知权限', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: _requestExactAlarmsPermission,
              child: const Text('去授权'),
            ),
          ],
        ),
      );
    }
  }

  /// 申请通知权限
  Future<void> _requestNotificationsPermission() async {
    final bool? grantedNotificationPermission =
        await androidImplementation?.requestNotificationsPermission();
    if (grantedNotificationPermission != true) {
      // 如果用户在申请权限时选择「不允许」一次或多次后，
      // 再次使用 androidImplementation?.requestNotificationsPermission() 不会再弹出系统的申请权限弹窗（允许/不允许），
      // 需要打开系统设置里本应用的通知设置页面。
      // [Android 11 中的权限更新  |  Android Developers](https://developer.android.com/about/versions/11/privacy/permissions?hl=zh-cn)
      // 如 ColorOS 是 2 次: [OPPO 开放平台-OPPO开发者服务中心](https://open.oppomobile.com/documentation/page/info?id=12983)
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  /// 申请精确通知权限
  Future<void> _requestExactAlarmsPermission() async {
    final bool? grantedExactAlarmsPermission =
        await androidImplementation?.requestExactAlarmsPermission();
    if (grantedExactAlarmsPermission != true) {
      AppSettings.openAppSettings(type: AppSettingsType.alarm);
    }
  }

  /// 测试通知(显示测试通知)
  Future<void> _showTestNotification() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      '这是一条测试通知',
      '如果您看到说明通知成功',
      notificationDetailsTestChannel,
    );
  }

  /// 测试定时通知(显示测试定时通知,即使应用不在运行)
  Future<void> _showTestScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '这是一条定时测试通知',
      '如果您看到说明测试定时通知成功',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetailsTestChannel,
      androidScheduleMode: AndroidScheduleMode
          .alarmClock, // TODO: 授予了 SCHEDULE_EXACT_ALARM 权限则使用 AndroidScheduleMode.alarmClock, 否则使用 AndroidScheduleMode.exactAllowWhileIdle
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    bool isEnableCourseNotification = context.select<SettingsProvider, bool>(
        (settingsProvider) => settingsProvider.isEnableCourseNotification);
    return Scaffold(
      appBar: AppBar(title: const Text("实验性功能")),
      body: ListView(
        children: [
          if (defaultTargetPlatform == TargetPlatform.android) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              child: SettingsSectionTitle(
                title: '上课提醒',
                iconData: Icons.notifications,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                tileColor: isEnableCourseNotification
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surfaceDim,
                leading: Align(
                  widthFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: isEnableCourseNotification
                      ? Icon(Icons.notifications_on)
                      : Icon(Icons.notifications_off),
                ),
                title: const Text('开启课程通知'),
                trailing: Switch(
                  value: isEnableCourseNotification,
                  onChanged: (value) {
                    if (value == true) {
                      _turnOnCourseNotification(context);
                    } else {
                      _turnOffCourseNotification(context);
                    }
                  },
                ),
              ),
            ),
            Selector<SettingsProvider, bool>(
                selector: (_, settingsProvider) =>
                    settingsProvider.isSilentNotification,
                builder: (_, isSilentNotification, __) {
                  return ListTile(
                    enabled: isEnableCourseNotification,
                    leading: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: isSilentNotification
                          ? Icon(Icons.notifications_paused)
                          : Icon(Icons.notifications_active),
                    ),
                    title: Text('静默通知'),
                    subtitle: Text('通知时不发出声音'),
                    trailing: Switch(
                      value: isSilentNotification,
                      onChanged: (value) {
                        context
                            .read<SettingsProvider>()
                            .setIsSilentNotification(value);
                      },
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              child: SettingsSectionTitle(
                title: '故障排除',
                iconData: Icons.troubleshoot,
              ),
            ),
            ListTile(
              title: Text('忽略电池优化'),
              subtitle: Text('针对部分国产深度定制系统'),
              onTap: () => AppSettings.openAppSettings(
                  type: AppSettingsType.batteryOptimization),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: _checkNotificationsPermission,
                  child: Text('检查通知权限'),
                ),
                TextButton(
                  onPressed: _checkExactAlarmsPermission,
                  child: Text('检查精确通知权限'),
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () => AppSettings.openAppSettings(
                      type: AppSettingsType.notification),
                  child: Text('打开通知设置'),
                ),
                TextButton(
                  onPressed: () =>
                      AppSettings.openAppSettings(type: AppSettingsType.alarm),
                  child: Text('打开精确通知设置'),
                ),
                TextButton(
                  onPressed: () => AppSettings.openAppSettings(
                      type: AppSettingsType.settings),
                  child: Text('打开应用设置'),
                ),
              ],
            ),

            // 测试通知
            Offstage(
              // offstage: !isEnableCourseNotification,
              offstage: false,
              child: ExpansionTile(
                leading: const Align(
                  widthFactor: 1,
                  alignment: Alignment.centerLeft,
                  // child: Icon(Icons.cruelty_free),
                  child: Icon(Icons.emoji_nature),
                ),
                title: const Text('测试通知'),
                children: [
                  TextButton(
                    onPressed: _showTestNotification,
                    child: Text('测试普通通知'),
                  ),
                  TextButton(
                    onPressed: _showTestScheduleNotification,
                    child: Text('测试定时通知(10s后通知)'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
