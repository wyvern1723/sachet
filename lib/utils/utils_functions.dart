import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:sachet/widgets/settingspage_widgets/logout_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

Future selectSemesterStartDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    locale: const Locale('zh', 'CN'),
    initialDate: SettingsProvider.semesterStartDateDateTime,
    firstDate: DateTime(1958, 6),
    lastDate: DateTime(2077, 12),
    selectableDayPredicate: (DateTime val) => val.weekday == 1 ? true : false,
    helpText: '选择学期开始日期',
  );
  if (!context.mounted) return;

  if (picked != null) {
    context
        .read<SettingsProvider>()
        .setSemesterStartDate(picked.toIso8601String());
  }
}

Future showLogoutDialog(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (BuildContext context) => LogoutDialog(),
  );

  if (!context.mounted) return;

  if (result == null) return;

  if (result == true) {
    context.read<ZhengFangUserProvider>().deleteUser();
  }
}

/// 打开链接
Future openLink(String link) async {
  LaunchMode launchMode = SettingsProvider.isOpenLinkInExternalBrowser
      ? LaunchMode.externalApplication
      : LaunchMode.inAppBrowserView;
  await launchUrl(Uri.parse(link), mode: launchMode);
}

void copyToClipboard(BuildContext context, String text, {String prefix = ''}) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$prefix已复制到剪贴板'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// 从获取课表默认保存的文件名提取当前学期
///
/// e.g.
///
/// "class_schedule_2025-2026-2_20260404155500" => "2025-2026-2"
///
/// "class_schedule_2025-2026-1_20250825111641" => "2025-2026-1"
String extractSemester(String filename) {
  final regex = RegExp(r'class_schedule_(\d{4}-\d{4}-\d+)');
  final match = regex.firstMatch(filename);

  if (match != null && match.groupCount >= 1) {
    return match.group(1)!;
  }

  // throw FormatException('无法从文件名 "$filename" 中提取学期信息');
  return filename;
}
