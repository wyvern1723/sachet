import 'package:flutter/material.dart';
import 'package:sachet/pages/utilspages/zhengfang_jwxt_login_page.dart';

class LoginExpiredZF extends StatelessWidget {
  /// 登录失效/登录过期提示重新登录的 Widget（正方教务系统）
  const LoginExpiredZF({
    super.key,
    this.onRetry,
  }) : isCompact = false;

  /// 登录失效/登录过期提示重新登录的 Widget 的 Compact 版本（更紧凑，适合空间有限的区域）
  const LoginExpiredZF.compact({
    super.key,
    this.onRetry,
  }) : isCompact = true;

  // 如果登录成功，从登录页面返回的回调函数
  final VoidCallback? onRetry;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 10.0 : 40.0,
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
                // Icons.account_circle_outlined,
                // Icons.sick_outlined,
                // Icons.sentiment_dissatisfied,
                Icons.sentiment_dissatisfied_outlined,
                size: isCompact ? 24 : 44,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 24),
            Text('登录已失效', style: textTheme.titleMedium),
            SizedBox(height: isCompact ? 4 : 12),
            Text(
              '教务系统登录已过期，请重新登录',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 24,
                  vertical: isCompact ? 2 : 8,
                ),
                visualDensity: isCompact ? VisualDensity.compact : null,
                textStyle: isCompact ? textTheme.labelSmall : null,
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const ZhengFangJwxtLoginPage();
                    },
                  ),
                ).then((value) {
                  onRetry?.call();
                });
              },
              icon: Icon(
                Icons.login,
                size: isCompact ? 14 : 18,
                applyTextScaling: true,
              ),
              label: const Text('重新登录'),
            ),
          ],
        ),
      ),
    );
  }
}
