import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sachet/utils/utils_funtions.dart';

/// 有新版本可用 Dialog
class NewVersionAvailableDialog extends StatelessWidget {
  const NewVersionAvailableDialog({
    super.key,
    required this.appVersion,
    required this.appBuildNumber,
    required this.latestTagName,
    required this.publishedDate,
    required this.apkSizeMB,
    required this.latestReleaseNote,
    required this.downloadLink,
    required this.latestTagUrl,
  });
  final String? appVersion;
  final String? appBuildNumber;

  /// 最新版本的 tag (版本号)
  final String? latestTagName;

  /// 发布日期
  final String? publishedDate;
  final String? apkSizeMB;

  /// releaseNote (更新内容)
  final String? latestReleaseNote;

  /// 最新一个 tag 的网页链接
  final String? latestTagUrl;

  /// 下载直链
  final String? downloadLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('有新版本可用'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            [
              '当前版本：v$appVersion ($appBuildNumber)',
              '最新版本：$latestTagName',
              '更新日期：$publishedDate',
              if (apkSizeMB != null) '安装包大小：$apkSizeMB MB',
            ].join('\n'),
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 4),
          Divider(),
          Text(
            '更新日志：',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: latestReleaseNote ?? '',
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        openLink(href);
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      String? url = latestTagUrl;
                      if (url != null) {
                        openLink(url);
                      }
                    },
                    child: const Text('查看详细信息', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('下次再说'),
        ),

        /// 如果成功根据当前系统和 abi 获取到对应的下载链接直接打开下载链接，如果没有则打开最新 Release 的链接
        (downloadLink == null)
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  String? url = latestTagUrl;
                  if (url != null) {
                    openLink(url);
                  }
                },
                child: const Text('去下载'),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  openLink(downloadLink!);
                },
                child: const Text('打开浏览器下载'),
              )
      ],
    );
  }
}
