import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/constants/app_info_constants.dart';
import 'package:sachet/models/github_latest_release_api_response.dart';
import 'package:sachet/pages/intro_screen/intro_screen.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/widgets/utils_widgets/disclaimer_dialog.dart';
import 'package:sachet/widgets/utils_widgets/new_version_available_dialog.dart';
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
    /// 最新 Release 的 TagName（我目前使用版本号作为 TagName，例如 v1.0.0）
    String? latestTagName = response.tagName;

    /// 最新 Tag 的 Release 的更新日志
    String? latestReleaseNote = response.body;

    final fileExtension = switch (defaultTargetPlatform) {
      TargetPlatform.android => '.apk',
      TargetPlatform.windows => '.zip',
      TargetPlatform.iOS => '.ipa',
      TargetPlatform.linux => '.tar.gz',
      TargetPlatform.macOS => '.dmg',
      _ => '',
    };
    ({String? downloadUrl, int? packageSize})? downloadLinkAndSize =
        getDownloadLinkAndSize(
      assetsList: response.assets,
      fileExtension: fileExtension,
      abi: abi,
    );

    /// 安装包下载链接
    String? downloadLink = downloadLinkAndSize.downloadUrl;

    /// 安装包大小
    int? packageSize = downloadLinkAndSize.packageSize;
    String? packageSizeMB = packageSize != null
        ? (packageSize / 1024 / 1024).toStringAsFixed(2)
        : null;

    /// 最新 Tag 的 Release 的链接
    String? latestTagUrl = response.htmlUrl;

    /// 最新 Tag 的 Release 的发布时间
    String? latestPublishedTime = response.publishedAt;

    /// 格式化后的最新 Tag 的 Release 的发布时间
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
        apkSizeMB: packageSizeMB,
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

  /// 显示 IntroScreen(引导页)
  static void showIntroScreen() {
    final context = NavigatorGlobal.navigatorKey.currentContext!;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => IntroScreen()),
      (Route route) => false,
    );
  }
}

/// 获取 Github Release 最新版本的信息
Future<GithubLatestReleaseApiResponse> getGithubReleaseLatest() async {
  try {
    var response = await Dio().get(checkAppUpdateAPI);

    GithubLatestReleaseApiResponse githubLatestReleaseApiResponse =
        GithubLatestReleaseApiResponse.fromJson(response.data);

    return githubLatestReleaseApiResponse;
  } on DioException catch (e) {
    if (kDebugMode) {
      print("error : ${e.response?.data}");
      print(e.type);
    }
    throw '';
  }
}

({String? downloadUrl, int? packageSize}) getDownloadLinkAndSize({
  required List<Assets>? assetsList,
  required String fileExtension,
  required String abi,
}) {
  if (assetsList == null) {
    return (downloadUrl: null, packageSize: null);
  }
  // 第一步，按文件后缀名筛选
  final filteredByExtension = assetsList
      .where((element) => element.name?.endsWith(fileExtension) == true);

  // 第二步，按 abi 查找
  final asset = filteredByExtension
      .firstWhereOrNull((e) => e.browserDownloadUrl?.contains(abi) == true);

  return (downloadUrl: asset?.browserDownloadUrl, packageSize: asset?.size);
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

Future<void> autoCheckUpdate() async {
  // 我不想一进入软件就弹更新，所以应用渲染出第一帧后延迟几秒，给个瞄个课表的时间。瞄完可以直接关闭软件了。
  await Future.delayed(const Duration(seconds: 4));
  checkUpdate(isShowDetails: false);
}
