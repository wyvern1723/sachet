import 'package:flutter/material.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/utils/services/path_provider_service.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/set_curve_duration_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/advanced_settings_widgets/set_curve_type_dialog.dart';
import 'package:provider/provider.dart';

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
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '动画设置',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.animation_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
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
                  title: const Text('课程表翻页动画'),
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
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '显示设置',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.build,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
          Selector<SettingsProvider, bool>(
              selector: (_, settingsProvider) =>
                  settingsProvider.isShowOccupiedOrEmptyText,
              builder: (_, isShowOccupiedOrEmptyText, __) {
                return ListTile(
                  leading: const Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.disabled_by_default_outlined),
                  ),
                  title: const Text('显示空闲课表的文字'),
                  subtitle: const Text('显示「空」和「满」'),
                  trailing: Switch(
                    value: isShowOccupiedOrEmptyText,
                    onChanged: (value) {
                      context
                          .read<SettingsProvider>()
                          .setIsShowOccupiedOrEmptyText(value);
                    },
                  ),
                );
              }),
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
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '应用设置',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.app_settings_alt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
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
