import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// 有新版本可用 Dialog
class NewVersionAvailableDialog extends StatelessWidget {
  final String? appVersion;
  final String? appBuildNumber;
  final String? latestTagName;
  final String? publishedDate;
  final String? apkSizeMB;
  final String? latestReleaseNote;
  final String? latestTagUrl;
  final String? downloadLink;

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('有新版本可用'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "当前版本： v$appVersion ($appBuildNumber)"
            "\n"
            "最新版本： $latestTagName"
            "\n"
            "更新日期： $publishedDate"
            "\n"
            "安装包大小： $apkSizeMB MB",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 4),
          Divider(),
          Text(
            '更新日志：',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: latestReleaseNote ?? '',
                    // style: Theme.of(context).textTheme.bodyMedium,
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(Uri.parse(href));
                      }
                    },
                  ),
                  // const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      String? _latestTagUrl = latestTagUrl;
                      if (_latestTagUrl != null) {
                        launchUrl(Uri.parse(_latestTagUrl));
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
          onPressed: () async {
            Navigator.pop(context);
          },
          child: const Text('下次再说'),
        ),
        // TextButton(
        //   onPressed: () async {
        //     Navigator.pop(context, 'Cancel');
        //   },
        //   child: const Text('明天再提醒我'),
        // ),
        // TextButton(
        //   onPressed: () async {
        //     // TODO: set isAutoCheckUpdate = false;
        //     // 关闭自动检查更新可能会错过重要更新，您确定吗？
        //     // 软件还不完善，每次更新都会尽力修复存在的问题和增加实用的功能。
        //     // 做到比上一个版本更好，不会反向升级。
        //     // 确有需要才会推送更新（小更新可以放在 beta 频道）
        //     // 我们推荐您使用最新版。
        //     Navigator.pop(context, 'Cancel');
        //   },
        //   child: const Text('永远不要提醒我'),
        // ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () async {
            Navigator.pop(context);
            String? _downloadLink = downloadLink;
            if (_downloadLink != null) {
              launchUrl(Uri.parse(_downloadLink));
            }
          },
          child: const Text('打开浏览器下载'),
        )
      ],
    );
  }
}
