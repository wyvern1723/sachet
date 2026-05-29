import 'package:flutter/material.dart';
import 'package:sachet/utils/transform.dart';

class ErrorWithRetryWidget extends StatelessWidget {
  /// 错误 Widget
  const ErrorWithRetryWidget({
    super.key,
    required this.text,
    this.onRetry,
    this.footer,
  }) : isCompact = false;

  /// 错误 Widget（Compact 版本（更紧凑，适合空间有限的区域））
  const ErrorWithRetryWidget.compact({
    super.key,
    required this.text,
    this.onRetry,
    this.footer,
  }) : isCompact = true;

  /// 错误提示文本
  final String text;

  /// 点击「重试」的回调函数（如果为 null 则不显示重试按钮）
  final VoidCallback? onRetry;
  final bool isCompact;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 8.0 : 40.0,
          horizontal: isCompact ? 16.0 : 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isCompact ? 48 : 80,
              height: isCompact ? 48 : 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(isCompact ? 16.0 : 24.0),
              ),
              child: Icon(
                dioExceptionTypeToText.values.any(
                  (keyword) => text.contains(keyword),
                )
                    ? Icons.cloud_off
                    : Icons.error_outline,
                size: isCompact ? 24 : 44,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 24),
            SelectionArea(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: text.contains(': ') && !text.endsWith(': ')
                          ? dioExceptionTypeToText.values.contains(
                                  text.substring(text.indexOf(': ') + 2))
                              ? '网络错误: ${text.substring(text.indexOf(': ') + 2)}'
                              : '错误'
                          : '错误',
                      style: textTheme.titleMedium,
                    ),
                    TextSpan(
                      text: '\n ',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.0,
                        color: Colors.transparent,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    WidgetSpan(
                      child: SelectionContainer.disabled(
                        child: SizedBox(
                          height: isCompact ? 4.0 : 24.0,
                          width: 0,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: text,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 24),
            if (onRetry != null)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 24,
                    vertical: isCompact ? 2 : 8,
                  ),
                  visualDensity: isCompact ? VisualDensity.compact : null,
                  textStyle: isCompact ? textTheme.labelSmall : null,
                ),
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh,
                  size: isCompact ? 14 : 18,
                  applyTextScaling: true,
                ),
                // label: const Text('重新加载'),
                label: const Text('重试'),
              ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
