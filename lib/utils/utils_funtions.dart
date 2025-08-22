import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/providers/qiangzhi_user_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/widgets/settingspage_widgets/logout_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

Future selectSemesterStartDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    locale: const Locale('zh', 'CN'),
    initialDate: DateTime.tryParse(SettingsProvider.semesterStartDate) ??
        constSemesterStartDate,
    firstDate: DateTime(1958, 6),
    lastDate: DateTime(2077, 12),
    selectableDayPredicate: (DateTime val) => val.weekday == 1 ? true : false,
    helpText: '选择学期开始日期',
  );

  if (picked != null) {
    context
        .read<SettingsProvider>()
        .setSemesterStartDate(picked.toIso8601String());
  }
}

enum JwxtType { qiangzhi, zhengfang }

Future showLogoutDialog(BuildContext context, JwxtType jwxtType) async {
  var result = await showDialog(
    context: context,
    builder: (BuildContext context) => LogoutDialog(),
  );
  if (result != null) {
    switch (jwxtType) {
      case JwxtType.qiangzhi:
        {
          context.read<QiangZhiUserProvider>().deleteUser();
          break;
        }
      case JwxtType.zhengfang:
        {
          break;
        }
      default:
    }
    // 如果返回 true,同时删除缓存数据
    if (result == true) {
      await CachedDataStorage().deleteAllCachedData();
    }
  }
}

/// 打开链接
Future openLink(String link) async {
  LaunchMode launchMode = SettingsProvider.isOpenLinkInExternalBrowser
      ? LaunchMode.externalApplication
      : LaunchMode.inAppBrowserView;
  await launchUrl(Uri.parse(link), mode: launchMode);
}
