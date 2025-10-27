import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sachet/models/course_reminder.dart';
import 'package:sachet/models/permission_check_item.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/settingspage_widgets/experimental_settings_widgets/check_list_tile.dart';
import 'package:sachet/widgets/settingspage_widgets/experimental_settings_widgets/compact_error_tile.dart';
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

/// 提前通知的时间（在上课多久前通知）
const Duration advanceDuration = Duration(minutes: 30);

class ExperimentalSettingsPage extends StatefulWidget {
  const ExperimentalSettingsPage({super.key});

  @override
  State<ExperimentalSettingsPage> createState() =>
      _ExperimentalSettingsPageState();
}

class _ExperimentalSettingsPageState extends State<ExperimentalSettingsPage> {
  /// 是否有通知权限
  bool _hasNotificationPermission = false;

  /// 是否有精确通知权限
  bool _hasExactNotificationPermission = false;

  /// 是否允许自启动
  bool _isAutoStartEnabled = false;

  /// 是否忽略电池优化
  bool _isBatteryOptimizationDisabled = false;

  /// 是否忽略电池优化(OEM)
  bool _isManufacturerBatteryOptimizationDisabled = false;

  /// 是否完成所有允许后台运行设置
  bool _isAllBatteryOptimizationDisabled = false;

  Future _init() async {
    await _initializeNotifications();
    await _checkAllPermission();
  }

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

    if (!mounted) return;

    final bool isEnableNotification =
        context.read<SettingsProvider>().isEnableCourseNotification;

    if (isEnableNotification) {
      _ensureNotificationPermission();
    }
  }

  /// 检查所有权限和设置（通知权限、精确通知权限、自启动权限、忽略电池优化……）
  Future _checkAllPermission() async {
    _hasNotificationPermission = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
    _hasExactNotificationPermission = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications() ??
        false;
    _isAutoStartEnabled =
        await DisableBatteryOptimization.isAutoStartEnabled ?? false;
    _isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
    _isManufacturerBatteryOptimizationDisabled =
        await DisableBatteryOptimization
                .isManufacturerBatteryOptimizationDisabled ??
            false;
    _isAllBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isAllBatteryOptimizationDisabled ??
            false;
    setState(() {});
  }

  /// （在用户开启了课程通知的前提下）确认是否具有通知权限
  Future<void> _ensureNotificationPermission() async {
    final bool? areEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    if (!mounted) return;

    if (areEnabled == false) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('需要通知权限'),
          content: Text(
            '您已开启上课提醒，但应用通知权限被关闭，课程通知功能需要此权限才能正常工作。',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: _requestNotificationsPermission,
              child: const Text('去授权'),
            ),
          ],
        ),
      );
    }
  }

  /// 开启课程通知（上课提醒）
  Future _turnOnCourseNotification(BuildContext context) async {
    // 检查是否具有通知权限
    bool hasNotificationPermission =
        await androidImplementation?.areNotificationsEnabled() ?? false;

    if (!hasNotificationPermission) {
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestNotificationsPermission();
                },
                child: const Text('去授权'),
              ),
            ],
          ),
        );

        // throw '未授予通知权限';
        return;
      }
    }

    // 检查是否有精确通知权限
    bool hasExactNotificationPermission =
        await androidImplementation?.canScheduleExactNotifications() ?? false;
    if (!hasExactNotificationPermission) {
      // 申请精确通知权限
      bool? grantedExactAlarmsPermission =
          await androidImplementation?.requestExactAlarmsPermission();

      if (!context.mounted) return;

      if (grantedExactAlarmsPermission != true) {
        // 权限被拒绝，可能是用户在系统弹出的权限申请弹窗点击了「不允许」，或是其他问题？（这个权限比较少见）
        // 向用户解释没有这个权限无法提供精确通知，但不授予也行，并提供「去授权」按钮
        final bool? useInExactNotification = await showDialog<bool?>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('未授予“精确闹钟”权限'),
            content: Text(
              '为了确保课程通知准时，建议开启“精确闹钟”权限。\n否则，当手机静置或进入省电模式时，通知可能会被严重延迟。',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('不授权（使用非精确通知）'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestExactAlarmsPermission();
                },
                child: const Text('去授权'),
              ),
            ],
          ),
        );
        if (useInExactNotification != true) {
          // 当用户通过点击 Dialog 外区域或使用返回键关闭弹窗 或 点击「去授权」，都不会返回 true
          // 即没有选择「使用非精确通知」。
          // 因为没有精确通知权限用户又不选择「使用非精确通知」
          // 所以将结束这个「开启课程通知」的过程

          // 因为不方便判断用户点击「去授权」后是否真的完成授权
          // 所以最简单的方法是结束这个「开启课程通知」的过程，关闭 Dialog，
          // 「去授权」返回后，用户发现开关还是关闭，便会再次点击「开启课程通知」来开启
          return;
        }
        // 如果用户选择「不授权（使用非精确通知）」，确认了要使用非精确通知，则继续执行后面的添加通知逻辑
      }
    }

    if (!context.mounted) return;

    if (!_isAutoStartEnabled) {
      final bool? result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('未授予自启动权限'),
          content: Text(
            '部分国产定制系统会限制应用后台启动。为了防止错过课程通知，请允许本应用自启动',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('不设置（通知可能无法送达）'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.pop(context);
                DisableBatteryOptimization.showEnableAutoStartSettings(
                    "允许自启动", "请在设置中允许应用自启动");
              },
              child: const Text('去设置'),
            ),
          ],
        ),
      );
      if (result != true) return;
    }

    if (!context.mounted) return;

    if (!_isBatteryOptimizationDisabled) {
      final bool? result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('未忽略电池优化/允许应用在后台运行'),
          content: Text(
            'Android 系统默认会对后台应用进行电池优化，可能导致通知延迟或丢失。建议为本应用“忽略电池优化”以确保通知正常触发。',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('不设置（通知可能无法送达）'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                DisableBatteryOptimization
                    .showDisableBatteryOptimizationSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        ),
      );
      if (result != true) return;
    }

    if (!context.mounted) return;

    if (!_isManufacturerBatteryOptimizationDisabled) {
      final bool? result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('未关闭厂商后台限制'),
          content: Text(
            '您的设备厂商可能有额外的后台管理策略，请在设置中允许本应用“后台运行”、“无限制”或“忽略电池优化”',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('不设置（通知可能无法送达）'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                DisableBatteryOptimization
                    .showDisableManufacturerBatteryOptimizationSettings(
                        "部分手机厂商有额外的电池优化设置", "请在设置中允许应用“后台运行”、“无限制”或“忽略电池优化”");
              },
              child: const Text('去设置'),
            ),
          ],
        ),
      );
      if (result != true) return;
    }

    if (!context.mounted) return;

    if (!_isAllBatteryOptimizationDisabled) {
      final bool? result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('后台运行权限未完全配置'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '为确保课程通知可靠送达，请完成以下设置：',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '•  授予自启动权限\n'
                '•  忽略应用电池优化\n'
                '•  允许应用在后台运行',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('不设置（通知可能无法送达）'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                DisableBatteryOptimization.showDisableAllOptimizationsSettings(
                  "允许自启动",
                  "请在设置中允许应用自启动",
                  "部分手机厂商有额外的电池优化设置",
                  "请在设置中允许应用应用“后台运行”、“无限制”或“忽略电池优化”",
                );
              },
              child: const Text('去授权'),
            ),
          ],
        ),
      );
      if (result != true) return;
    }

    // 先取消所有待发送的通知
    await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();

    if (!context.mounted) return;

    bool isSilent = context.read<SettingsProvider>().isSilentNotification;

    // 设置通知（添加通知）
    try {
      await _addCourseScheduleNotifications(context, isSilent: isSilent);
    } catch (e) {
      if (!context.mounted) return;

      await _showAddNotificationsFailedDialog(context, '$e');

      return;
    }

    if (!context.mounted) return;

    // 将「启用课程通知」状态设为启用
    context.read<SettingsProvider>().setIsEnableCourseNotification(true);
  }

  /// 关闭课程通知
  Future<void> _turnOffCourseNotification(BuildContext context) async {
    // 取消所有 schedule 通知
    await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();

    if (!context.mounted) return;

    // 将「启用课程通知」状态设为关闭
    context.read<SettingsProvider>().setIsEnableCourseNotification(false);
  }

  /// 显示添加课程通知失败 Dialog
  Future<void> _showAddNotificationsFailedDialog(
      BuildContext context, String errorMessage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('添加课程通知失败'),
        content: Text(errorMessage, style: TextStyle(fontSize: 16)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 检查通知权限
  ///
  /// 成功: 弹出 "通知权限已启用" Dialog
  ///
  /// 失败: 弹出 "未授予通知权限，去授权" Dialog
  Future<void> _checkNotificationsPermission() async {
    final bool areEnabled = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    if (!mounted) return;

    if (areEnabled != _hasNotificationPermission) {
      setState(() {
        _hasNotificationPermission = areEnabled;
      });
    }

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
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _requestNotificationsPermission();
                Navigator.pop(context);
              },
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
    final bool areEnabled = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications() ??
        false;

    if (!mounted) return;

    if (areEnabled != _hasExactNotificationPermission) {
      setState(() {
        _hasExactNotificationPermission = areEnabled;
      });
    }

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
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _requestExactAlarmsPermission();
                Navigator.pop(context);
              },
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

  /// 检查是否允许自启动
  ///
  /// 成功: 弹出 "已允许自启动" Dialog
  ///
  /// 失败: 弹出 "未授予自启动权限，去授权" Dialog
  Future<void> _checkAutoStart() async {
    final bool isAutoStartEnabled =
        await DisableBatteryOptimization.isAutoStartEnabled ?? false;

    if (!mounted) return;

    if (isAutoStartEnabled != _isAutoStartEnabled) {
      setState(() {
        _isAutoStartEnabled = isAutoStartEnabled;
      });
    }

    if (isAutoStartEnabled == true) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('已允许应用自启动', style: TextStyle(fontSize: 18)),
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
          content: Text('未授予自启动权限', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DisableBatteryOptimization.showEnableAutoStartSettings(
                    "允许自启动", "请在设置中允许应用自启动");
              },
              child: const Text('去授权'),
            ),
          ],
        ),
      );
    }
  }

  /// 检查是否禁用了电量优化
  ///
  /// 成功: 弹出 "已忽略电量优化" Dialog
  ///
  /// 失败: 弹出 "未忽略电量优化，去授权" Dialog
  Future<void> _checkIsBatteryOptimizationDisabled() async {
    final bool isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;

    if (!mounted) return;

    if (isBatteryOptimizationDisabled != _isBatteryOptimizationDisabled) {
      setState(() {
        _isBatteryOptimizationDisabled = isBatteryOptimizationDisabled;
      });
    }

    if (isBatteryOptimizationDisabled == true) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('已忽略电池优化', style: TextStyle(fontSize: 18)),
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
          content: Text('未忽略电池优化', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DisableBatteryOptimization
                    .showDisableBatteryOptimizationSettings();
              },
              child: const Text('去授权'),
            ),
          ],
        ),
      );
    }
  }

  /// 检查是否禁用了电量优化（manufacturer(Android 定制系统，如 Xiaomi、Huawei、Oppo、Vivo)）
  ///
  /// 成功: 弹出 "已忽略制造商的电量优化" Dialog
  ///
  /// 失败: 弹出 "未忽略制造商的电量优化，去授权" Dialog
  Future<void> _checkIsManufacturerBatteryOptimizationDisabled() async {
    final bool isManufacturerBatteryOptimizationDisabled =
        await DisableBatteryOptimization
                .isManufacturerBatteryOptimizationDisabled ??
            false;

    if (!mounted) return;

    if (isManufacturerBatteryOptimizationDisabled !=
        _isManufacturerBatteryOptimizationDisabled) {
      setState(() {
        _isManufacturerBatteryOptimizationDisabled =
            isManufacturerBatteryOptimizationDisabled;
      });
    }

    if (isManufacturerBatteryOptimizationDisabled == true) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('已忽略手机厂商的电池优化', style: TextStyle(fontSize: 18)),
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
          content: Text('未忽略手机厂商的电量优化', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DisableBatteryOptimization
                    .showDisableManufacturerBatteryOptimizationSettings(
                        "部分手机厂商有额外的电池优化设置", "请在设置中允许应用在后台运行/无限制/忽略电池优化");
              },
              child: const Text('去授权'),
            ),
          ],
        ),
      );
    }
  }

  /// 检查是否禁用了所有电量优化设置（自启动、电池优化、电池优化(OEM))
  ///
  /// 成功: 弹出 "已完成所有允许应用在后台运行的设置" Dialog
  ///
  /// 失败: 弹出 "未已完成所有允许应用在后台运行的设置，去授权" Dialog
  Future<void> _checkIsAllBatteryOptimizationDisabled() async {
    final bool isAllBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isAllBatteryOptimizationDisabled ??
            false;

    if (!mounted) return;

    if (isAllBatteryOptimizationDisabled != _isAllBatteryOptimizationDisabled) {
      setState(() {
        _isAllBatteryOptimizationDisabled = isAllBatteryOptimizationDisabled;
      });
    }

    if (isAllBatteryOptimizationDisabled == true) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('已完成所有允许应用在后台运行的设置', style: TextStyle(fontSize: 18)),
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
          content: Text('未已完成所有允许应用在后台运行设置', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DisableBatteryOptimization.showDisableAllOptimizationsSettings(
                  "允许自启动",
                  "请在设置中允许应用自启动",
                  "部分手机厂商有额外的电池优化设置",
                  "请在设置中允许应用在后台运行/无限制/忽略电池优化",
                );
              },
              child: const Text('去授权'),
            ),
          ],
        ),
      );
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
    // 是否有精确通知权限，如果有，使用精确通知，否则使用非精确通知
    bool isExactNotification =
        await androidImplementation?.canScheduleExactNotifications() ?? false;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '这是一条定时测试通知',
      '如果您看到说明测试定时通知成功',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetailsTestChannel,
      androidScheduleMode: isExactNotification
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// 添加课程通知
  Future _addCourseScheduleNotifications(BuildContext context,
      {bool isSilent = false}) async {
    List<CourseReminder> reminders = await context
        .read<SettingsProvider>()
        .generateCourseScheduleReminders();
    // 是否有精确通知权限，如果有，使用精确通知，否则使用非精确通知
    bool isExactNotification =
        await androidImplementation?.canScheduleExactNotifications() ?? false;
    for (var i = 0; i < reminders.length; i++) {
      await _addOneCourseNotification(
        id: i + 1,
        courseStartTime: reminders[i].courseStartDateTime,
        courseTitle: reminders[i].courseTitle,
        coursePlace: reminders[i].coursePlace,
        courseInstructor: reminders[i].courseInstructor,
        courseStartTimeStr: reminders[i].courseStartTimeStr,
        courseEndTimeStr: reminders[i].courseEndTimeStr,
        courseDurationInMilliseconds: reminders[i].courseDurationInMilliseconds,
        isSilent: isSilent,
        isExactNotification: isExactNotification,
      );
    }
  }

  /// 添加一条课程通知
  Future<void> _addOneCourseNotification({
    required int id,
    required DateTime courseStartTime,
    required String courseTitle,
    required String coursePlace,
    required String courseInstructor,
    required String courseStartTimeStr,
    required String courseEndTimeStr,
    required int courseDurationInMilliseconds, // 这次课对应的毫秒数(课程结束后通知自动消失)
    required bool isSilent, // 是否静默通知
    required bool
        isExactNotification, // true => 使用 alarmClock,false => 使用 exactAllowWhileIdle
  }) async {
    String startAndEndTime = '$courseStartTimeStr - $courseEndTimeStr';
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '$courseTitle | $coursePlace',
      startAndEndTime,
      tz.TZDateTime.from(courseStartTime.subtract(advanceDuration), tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'course_reminder',
          '上课提醒',
          channelDescription: '在上课前通过通知提醒',
          icon: "ic_notification",
          importance: Importance.max,
          priority: Priority.high,
          timeoutAfter:
              courseDurationInMilliseconds + advanceDuration.inMilliseconds,
          usesChronometer: true,
          chronometerCountDown: true,
          when: courseStartTime.millisecondsSinceEpoch,
          silent: isSilent,
        ),
      ),
      androidScheduleMode: isExactNotification
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// 启用静默通知
  Future _enableSilentNotification(BuildContext context) async {
    // 先取消所有已安排、待发送的通知
    await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();

    if (!context.mounted) return;

    // 重新安排通知
    try {
      await _addCourseScheduleNotifications(context, isSilent: true);
    } catch (e) {
      if (!context.mounted) return;

      await _showAddNotificationsFailedDialog(context, '$e');

      // 如果添加课程失败，取消所有待发送的通知并将「开始课程通知」开关关闭
      await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();
      if (!context.mounted) return;
      context.read<SettingsProvider>().setIsEnableCourseNotification(false);

      return;
    }

    if (!context.mounted) return;

    context.read<SettingsProvider>().setIsSilentNotification(true);
  }

  /// 关闭静默通知
  Future _disableSilentNotification(BuildContext context) async {
    // 先取消所有已安排、待发送的通知
    await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();

    if (!context.mounted) return;

    // 重新安排通知
    try {
      await _addCourseScheduleNotifications(context, isSilent: false);
    } catch (e) {
      if (!context.mounted) return;

      await _showAddNotificationsFailedDialog(context, '$e');

      if (!context.mounted) return;

      // 如果添加课程失败，取消所有待发送的通知并将「开始课程通知」开关关闭
      await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();
      if (!context.mounted) return;
      context.read<SettingsProvider>().setIsEnableCourseNotification(false);
      return;
    }

    if (!context.mounted) return;
    context.read<SettingsProvider>().setIsSilentNotification(false);
  }

  Future<void> _checkPendingNotificationRequests(BuildContext context) async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          '共有 ${pendingNotificationRequests.length} 条已安排的通知',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...pendingNotificationRequests.map(
                (e) => ListTile(
                  leading: Text('ID: ${e.id}'),
                  title: Text('${e.title}'),
                  subtitle: Text('${e.body}'),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    bool isEnableCourseNotification = context.select<SettingsProvider, bool>(
        (settingsProvider) => settingsProvider.isEnableCourseNotification);

    final List<PermissionCheckItem> permissionItems = [
      PermissionCheckItem(
        title: '通知权限',
        value: _hasNotificationPermission,
        onTap: _checkNotificationsPermission,
        errorMsg: '通知权限未授予，无法发送通知',
      ),
      PermissionCheckItem(
        title: '精确通知权限',
        value: _hasExactNotificationPermission,
        onTap: _checkExactAlarmsPermission,
        errorMsg: '精确通知权限未授予，当手机静置或进入省电模式时，通知可能会被严重延迟',
      ),
      PermissionCheckItem(
        title: '允许自启动',
        value: _isAutoStartEnabled,
        onTap: _checkAutoStart,
        errorMsg: '自启动权限未授予，可能无法正常唤醒应用发送通知',
      ),
      PermissionCheckItem(
        title: '忽略电池优化/允许后台运行',
        value: _isBatteryOptimizationDisabled,
        onTap: _checkIsBatteryOptimizationDisabled,
        errorMsg: '未忽略电池优化，可能无法发送通知',
      ),
      PermissionCheckItem(
        title: '忽略电池优化/允许后台运行(OEM)',
        value: _isManufacturerBatteryOptimizationDisabled,
        onTap: _checkIsManufacturerBatteryOptimizationDisabled,
        errorMsg: '未忽略手机厂商的电池优化，可能无法发送通知',
      ),
      PermissionCheckItem(
        title: '所有允许后台运行设置',
        value: _isAllBatteryOptimizationDisabled,
        onTap: _checkIsAllBatteryOptimizationDisabled,
        errorMsg: '未完成所有允许应用在后台运行的设置，可能无法发送通知',
      ),
    ];

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

            // 课程通知开关
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

            // 静默通知开关
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
                        if (value == true) {
                          _enableSilentNotification(context);
                        } else {
                          _disableSilentNotification(context);
                        }
                      },
                    ),
                  );
                }),

            // 故障排除
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              child: SettingsSectionTitle(
                title: '故障排除',
                iconData: Icons.troubleshoot,
              ),
            ),

            // 显示各项权限是否具有
            ...permissionItems.map(
              (e) => CheckListTile(
                title: e.title,
                value: e.value,
                onTap: e.onTap,
              ),
            ),

            // 对于没有权限的项目，在下面显示 ⚠警告信息
            for (final permissionItem in permissionItems)
              if (permissionItem.value != true)
                CompactErrorTile(errorMsg: permissionItem.errorMsg),
            Divider(),

            // 手动打开各项设置页面
            ListTile(
              leading: Icon(Icons.edit_notifications),
              title: Text('通知设置'),
              trailing: Icon(Icons.open_in_new),
              onTap: () => AppSettings.openAppSettings(
                  type: AppSettingsType.notification),
            ),
            ListTile(
              leading: Icon(Icons.app_settings_alt),
              title: Text('应用设置'),
              trailing: Icon(Icons.open_in_new),
              onTap: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.settings),
            ),
            ListTile(
              leading: Icon(Icons.battery_saver),
              title: Text('电池优化设置'),
              trailing: Icon(Icons.open_in_new),
              onTap: () => AppSettings.openAppSettings(
                  type: AppSettingsType.batteryOptimization),
            ),
            ListTile(
              leading: Icon(Icons.access_alarm),
              title: Text('精确通知设置'),
              trailing: Icon(Icons.open_in_new),
              onTap: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.alarm),
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
                  TextButton(
                    onPressed: () => _checkPendingNotificationRequests(context),
                    child: Text('查看已安排的通知'),
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
