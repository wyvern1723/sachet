import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/widgets/utils_widgets/disclaimer_dialog.dart';
import 'package:sachet/widgets/utils_widgets/new_version_available_dialog.dart';
import 'package:sachet/model/get_web_data/check_update.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SnackbarGlobal {
  static GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static void hide() {
    key.currentState!.hideCurrentSnackBar();
  }

  /// 显示正在检查更新的 SnackBar
  static void showCheckingUpdate() {
    final context = NavigatorGlobal.navigatorKey.currentContext!;
    final snackbar = SnackBar(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Text(
            '检查更新中...',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface),
          ),
        ],
      ),
    );
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(snackbar);
  }

  /// 显示已是最新版的 SnackBar
  static void showIsNewestVersion() {
    final context = NavigatorGlobal.navigatorKey.currentContext!;
    final snackbar = SnackBar(
      content: Row(
        children: [
          const SizedBox(width: 20),
          Text(
            '已是最新版',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
    );
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(snackbar);
  }

  /// 显示更新错误 SnackBar
  static void showErrorSnackbar() {
    final context = NavigatorGlobal.navigatorKey.currentContext!;
    final snackbar = SnackBar(
      backgroundColor: Theme.of(context).colorScheme.onErrorContainer,
      content: Row(
        children: [
          Icon(Icons.warning,
              color: Theme.of(context).colorScheme.errorContainer),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              '从 Github 服务器获取更新信息失败',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
    );
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(snackbar);
  }
}

class NavigatorGlobal {
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// 显示有新版本可用的 AlertDialog
  static void showNewVersionDialog(
    String appVersion,
    String appBuildNumber,
    GithubLatestReleaseApiResponse response,
  ) {
    String? latestTagName = response.tagName;
    String? latestReleaseNote = response.body;
    MapEntry<String?, int?> downloadLinkAndSize = getDownloadLinkAndSize(
      assetsList: response.assets!,
      fileExtension: '.apk',
      abi: abi,
    );
    String? downloadLink = downloadLinkAndSize.key;
    int? apkSize = downloadLinkAndSize.value;
    String? apkSizeMB =
        apkSize != null ? (apkSize / 1024 / 1024).toStringAsFixed(2) : null;
    String? latestTagUrl = response.htmlUrl;
    String? latestPublishedTime = response.publishedAt;
    String? publishedDate = latestPublishedTime != null
        ? DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(latestPublishedTime).toLocal())
        : null;

    final context = NavigatorGlobal.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (BuildContext context) => NewVersionAvailableDialog(
        appVersion: appVersion,
        appBuildNumber: appBuildNumber,
        latestTagName: latestTagName,
        publishedDate: publishedDate,
        apkSizeMB: apkSizeMB,
        latestReleaseNote: latestReleaseNote,
        downloadLink: downloadLink,
        latestTagUrl: latestTagUrl,
      ),
    );
  }

  /// 显示 声明 Dialog
  static void showDisclaimerDialog() {
    final context = NavigatorGlobal.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (BuildContext context) => DisclaimerDialog(),
    );
  }
}

void autoCheckUpdate() async {
  // 我不想一进入软件就弹更新，所以应用渲染出第一帧后延迟几秒，给个瞄个课表的时间。瞄完可以直接关闭软件了。
  await Future.delayed(const Duration(seconds: 4));
  checkUpdate(isShowDetails: false);
}

Future checkUpdate({bool? isShowDetails = false}) async {
  // 显示正在检查更新 snackbar
  if (isShowDetails == true) {
    SnackbarGlobal.showCheckingUpdate();
  }

  // 获取 App 当前版本
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appVersion = packageInfo.version;
  String appBuildNumber = packageInfo.buildNumber;

  // 获取更新数据(getGithubReleaseLatest)，然后传出结果(latestDataList)
  getGithubReleaseLatest().then((GithubLatestReleaseApiResponse response) {
    var latestTagName = response.tagName;
    if (latestTagName == 'v$appVersion' ||
        latestTagName == 'V$appVersion' ||
        latestTagName == appVersion) {
      // 如果设置显示所有检查更新结果(isShowResult)，显示已是最新版的 snackbar
      if (SettingsProvider.isShowAllCheckUpdateResult ||
          isShowDetails == true) {
        SnackbarGlobal.showIsNewestVersion();
      }
    } else {
      // 隐藏正在检查更新的 snackbar
      SnackbarGlobal.hide();

      // 显示有新版本可用的 dialog
      NavigatorGlobal.showNewVersionDialog(
        appVersion,
        appBuildNumber,
        response,
      );
    }
  }, onError: (Object error) async {
    // print(error);

    // 隐藏正在检查更新的 snackbar
    SnackbarGlobal.hide();

    // 如果设置显示所有检查更新结果(isShowResult)，显示检查更新错误 snackbar
    if (SettingsProvider.isShowAllCheckUpdateResult || isShowDetails == true) {
      SnackbarGlobal.showErrorSnackbar();
    }
    await Future.delayed(const Duration(seconds: 2));
  });
}

MapEntry<String?, int?> getDownloadLinkAndSize({
  required List<Assets> assetsList,
  required String fileExtension,
  required String abi,
}) {
  // 第一步，筛选文件后缀名
  // 符合文件后缀名的 List
  List<Assets> extensionList = assetsList
      .where((element) => element.name!.endsWith(fileExtension))
      .toList();
  // 第二步筛选 abi
  Map<String?, int?> downloadUrlAndSizeMap = {};
  extensionList.forEach(
      (e) => downloadUrlAndSizeMap.addAll({e.browserDownloadUrl: e.size}));

  MapEntry<String?, int?> downloadLinkAndSize =
      downloadUrlAndSizeMap.entries.firstWhere(
    (element) => element.key!.contains(abi),
    orElse: () {
      return downloadUrlAndSizeMap.entries.first;
    },
  );

  return downloadLinkAndSize;
}
