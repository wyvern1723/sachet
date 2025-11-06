import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/models/page_transitions_type.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/theme_provider.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/page_transitions_dropdownmenu.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/set_curve_duration_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/set_curve_type_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/set_free_classroom_sections_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/settings_section_title.dart';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scaffoldMessenger.hideCurrentSnackBar();
    super.dispose();
  }

  Future showDeleteCachedDataDialog() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('删除缓存数据'),
        content: const Text('确定要删除所有缓存数据？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (result == true) {
      await CachedDataStorage().deleteAllCachedData();
      _scaffoldMessenger.showSnackBar(SnackBar(content: Text('删除成功！')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("高级设置"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: SettingsSectionTitle(
              title: '应用动画',
              iconData: Icons.animation_outlined,
            ),
          ),

          // 页面过渡动画设置
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              // child: Icon(Icons.web_stories_outlined),
              // TODO: 寻找更合适的 Icon
              child: Icon(Icons.animation_outlined),
            ),
            title: Text('页面过渡'), // PageTransition
            subtitle: Text('页面过渡动画'),
            trailing: PageTransitionsDropdownmenu(),
          ),

          // 预测性返回开关
          if (defaultTargetPlatform == TargetPlatform.android)
            Selector<ThemeProvider, String>(
                selector: (_, themeProvider) => themeProvider.pageTransition,
                builder: (_, pageTransition, __) {
                  return Offstage(
                    offstage:
                        pageTransition != PageTransitionsType.zoom.storageValue,
                    child: ListTile(
                      leading: Align(
                        widthFactor: 1,
                        alignment: Alignment.centerLeft,
                        // child: Icon(Icons.fiber_smart_record_outlined)
                        // TODO: 寻找更合适的 Icon
                        child: Icon(Icons.toll_outlined),
                      ),
                      title: Text('预测性返回'),
                      subtitle: Text('启用预测性返回（预见式返回）手势 (Android 14+)'),
                      trailing: Selector<ThemeProvider, bool>(
                          selector: (_, themeProvider) =>
                              themeProvider.isPredictiveBack,
                          builder: (_, isPredictiveBack, __) {
                            return Switch(
                              value: isPredictiveBack,
                              onChanged: (value) {
                                context
                                    .read<ThemeProvider>()
                                    .setPredictiveBack(value);
                              },
                            );
                          }),
                    ),
                  );
                }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: SettingsSectionTitle(
              title: '课程表页面动画',
              iconData: Icons.animation_outlined,
            ),
          ),
          // 翻页动画
          Selector<SettingsProvider, String>(
              selector: (_, settingsProvider) => settingsProvider.curveType,
              builder: (_, curveType, __) {
                return ListTile(
                  leading: const Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.view_array_outlined),
                  ),
                  title: const Text('翻页动画类型'),
                  subtitle: Text(curveType),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => SetCurveTypeDialog(),
                    );
                  },
                );
              }),
          Selector<SettingsProvider, int>(
              selector: (_, settingsProvider) => settingsProvider.curveDuration,
              builder: (_, curveDuration, __) {
                return ListTile(
                  leading: const Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.timer_outlined),
                  ),
                  title: const Text('翻页动画时长'),
                  subtitle: Text('$curveDuration ms'),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => SetCurveDurationDialog(),
                    );
                  },
                );
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: SettingsSectionTitle(
              title: '显示设置',
              iconData: Icons.build,
            ),
          ),
          Selector<SettingsProvider, bool>(
              selector: (_, settingsProvider) =>
                  settingsProvider.isShowPageTurnArrow,
              builder: (_, isShowPageTurnArrow, __) {
                return ListTile(
                  leading: Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: isShowPageTurnArrow
                        ? const Icon(Icons.switch_right_outlined)
                        : const Icon(Icons.do_not_disturb_outlined),
                  ),
                  title: const Text('显示翻页箭头按钮'),
                  subtitle: Text('课程表页面切换上一周/下一周的按钮'),
                  trailing: Switch(
                    value: isShowPageTurnArrow,
                    onChanged: (value) {
                      context
                          .read<SettingsProvider>()
                          .setIsShowPageTurnArrow(value);
                    },
                  ),
                );
              }),
          Selector<SettingsProvider, List>(
              selector: (_, settingsProvider) =>
                  settingsProvider.freeClassroomSections,
              builder: (_, sections, __) {
                return ListTile(
                  leading: const Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.horizontal_split),
                  ),
                  title: const Text('空闲教室查询节次分段'),
                  subtitle: Text('${sections.join(',  ')}'),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => SetFreeClassroomSectionsDialog(),
                    );
                  },
                );
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: SettingsSectionTitle(
              title: '应用设置',
              iconData: Icons.app_settings_alt,
            ),
          ),
          Selector<SettingsProvider, bool>(
              selector: (_, settingsProvider) =>
                  SettingsProvider.isAutoCheckUpdate,
              builder: (_, isAutoCheckUpdate, __) {
                return ListTile(
                  leading: Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: isAutoCheckUpdate
                        ? const Icon(Icons.update_outlined)
                        : const Icon(Icons.update_disabled_outlined),
                  ),
                  title: const Text('自动检查更新'),
                  subtitle: const Text('应用启动时自动检查更新'),
                  trailing: Switch(
                    value: isAutoCheckUpdate,
                    onChanged: (value) {
                      context
                          .read<SettingsProvider>()
                          .setIsAutoCheckUpdate(value);
                    },
                  ),
                );
              }),
          // AnimatedOpacity(
          //   opacity: _isAutoCheckUpdate ? 1 : 0,
          //   duration: const Duration(milliseconds: 200),
          //   child: ListTile(
          //     leading: const Align(
          //       widthFactor: 1,
          //       alignment: Alignment.centerLeft,
          //       // child: isAutoCheckUpdate
          //       //     ? const Icon(Icons.sms_failed_outlined)
          //       //     : const Icon(Icons.do_not_disturb_outlined),
          //       child: Icon(Icons.disabled_by_default_outlined),
          //     ),
          //     title: const Text('显示所有检查更新结果'),
          //     // 大多数用户可能链接到 Github 困难，每次打开应用都弹出检查失败的信息不太好，默认为不显示检查失败的信息。
          //     subtitle: const Text('显示「已是最新版」和「检查更新失败」，而不是仅会显示「有新版本可用」'),
          //     trailing: Switch(
          //       value: isShowResult,
          //       onChanged: (value) {
          //         setState(() {
          //           // isShowResult = value;
          //           setIsShowResult(value);
          //         });
          //       },
          //     ),
          //   ),
          // ),

          // 方案二，如果下面还有其他 ListTile 的话。
          Selector<SettingsProvider,
                  ({bool isAutoCheckUpdate, bool isShowAllCheckUpdateResult})>(
              selector: (_, settingsProvider) => (
                    isAutoCheckUpdate: SettingsProvider.isAutoCheckUpdate,
                    isShowAllCheckUpdateResult:
                        SettingsProvider.isShowAllCheckUpdateResult
                  ),
              builder: (_, data, __) {
                return Offstage(
                  offstage: !data.isAutoCheckUpdate,
                  child: ListTile(
                    leading: const Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      // child: isAutoCheckUpdate
                      //     ? const Icon(Icons.sms_failed_outlined)
                      //     : const Icon(Icons.do_not_disturb_outlined),
                      child: Icon(Icons.disabled_by_default_outlined),
                    ),
                    title: const Text('显示所有检查更新结果'),
                    // 大多数用户可能链接到 Github 困难，每次打开应用都弹出检查失败的信息不太好，默认为不显示检查失败的信息。
                    subtitle: const Text('显示「已是最新版」和「检查更新失败」，而不是仅会显示「有新版本可用」'),
                    trailing: Switch(
                      value: data.isShowAllCheckUpdateResult,
                      onChanged: (value) {
                        context
                            .read<SettingsProvider>()
                            .setIsShowUpdateFailedResult(value);
                      },
                    ),
                  ),
                );
              }),

          // 是否在外部浏览器打开链接开关
          if (defaultTargetPlatform == TargetPlatform.android)
            Selector<SettingsProvider, bool>(
                selector: (_, settingsProvider) =>
                    SettingsProvider.isOpenLinkInExternalBrowser,
                builder: (_, isOpenLinkInExternalBrowser, __) {
                  return ListTile(
                    leading: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: isOpenLinkInExternalBrowser
                          ? const Icon(Icons.open_in_new)
                          : const Icon(Icons.open_in_new_off),
                    ),
                    title: const Text('在外部浏览器打开链接'),
                    subtitle: isOpenLinkInExternalBrowser
                        ? const Text('在外部浏览器打开（打开链接时离开应用）')
                        : const Text('在 Android Custom Tabs 打开（打开链接时不离开应用）'),
                    trailing: Switch(
                      value: isOpenLinkInExternalBrowser,
                      onChanged: (value) {
                        context
                            .read<SettingsProvider>()
                            .setIsOpenLinkInExternalBrowser(value);
                      },
                    ),
                  );
                }),
          if (defaultTargetPlatform == TargetPlatform.iOS)
            Selector<SettingsProvider, bool>(
                selector: (_, settingsProvider) =>
                    SettingsProvider.isOpenLinkInExternalBrowser,
                builder: (_, isOpenLinkInExternalBrowser, __) {
                  return ListTile(
                    leading: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: isOpenLinkInExternalBrowser
                          ? const Icon(Icons.open_in_new)
                          : const Icon(Icons.open_in_new_off),
                    ),
                    title: const Text('在外部浏览器打开链接'),
                    subtitle: isOpenLinkInExternalBrowser
                        ? const Text('在外部浏览器打开（打开链接时离开应用）')
                        : const Text('在 SFSafariViewController 打开（打开链接时不离开应用）'),
                    trailing: Switch(
                      value: isOpenLinkInExternalBrowser,
                      onChanged: (value) {
                        context
                            .read<SettingsProvider>()
                            .setIsOpenLinkInExternalBrowser(value);
                      },
                    ),
                  );
                }),

          // 自动识别图片验证码开关
          Selector<SettingsProvider, bool>(
              selector: (_, settingsProvider) =>
                  SettingsProvider.isEnableCaptchaRecognizer,
              builder: (_, isEnableCaptchaRecognizer, __) {
                return ListTile(
                  leading: Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.filter_center_focus_outlined),
                  ),
                  title: const Text('自动识别图片验证码'),
                  subtitle: const Text('Powered by TensorFlow'),
                  trailing: Switch(
                    value: isEnableCaptchaRecognizer,
                    onChanged: (bool value) {
                      context
                          .read<SettingsProvider>()
                          .setIsEnableCaptchaRecognizer(value);
                    },
                  ),
                );
              }),

          // 删除缓存数据
          ListTile(
            leading: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.delete_forever),
            ),
            title: const Text('删除缓存数据'),
            subtitle: const Text('删除「培养方案」、「考试时间」的缓存数据（不包括课程表）'),
            onTap: () async {
              await showDeleteCachedDataDialog();
            },
          ),
        ],
      ),
    );
  }
}
