import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sachet/utils/utils_functions.dart';

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 0),
      actionsPadding: EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.system_update_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text('有新版本可用', style: textTheme.headlineSmall),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // 当前版本
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '当前版本',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'v$appVersion',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: colorScheme.primary,
                  size: 20,
                  applyTextScaling: true,
                ),
              ),
              // 最新版本
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '最新版本',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '$latestTagName',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // 发布日期和安装包大小
          OverflowBar(
            alignment: MainAxisAlignment.center,
            overflowAlignment: OverflowBarAlignment.center,
            children: [
              // 发布日期
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 13,
                    applyTextScaling: true,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$publishedDate',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // 分隔圆点 (仅在 apkSize 不为空时显示)
              if (apkSizeMB != null)
                Container(
                  width: 3,
                  height: 3,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),

              // 安装包大小 (仅在 apkSize 不为空时显示)
              if (apkSizeMB != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.install_mobile_outlined,
                      size: 13,
                      applyTextScaling: true,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '大小：$apkSizeMB MB',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          SizedBox(height: 8),

          // 更新日志
          Flexible(
            child: Container(
              // constraints: const BoxConstraints(maxHeight: 500),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Icon(
                        Icons.feed_outlined,
                        size: 16,
                        applyTextScaling: true,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '更新日志：',
                        style: textTheme.titleSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ]),
                    SizedBox(height: 4),
                    MarkdownBody(
                      data: latestReleaseNote ?? '',
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          openLink(href);
                        }
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: textTheme.bodyMedium,
                        listIndent: 16,
                        blockSpacing: 4,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        String? url = latestTagUrl;
                        if (url != null) {
                          openLink(url);
                        }
                      },
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.fromLTRB(2, 0, 2, 0)),
                        visualDensity: VisualDensity.compact,
                        alignment: Alignment.center,
                      ),
                      child: Text(
                        '查看详细信息',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
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
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
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
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
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
