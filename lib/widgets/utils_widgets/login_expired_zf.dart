import 'package:flutter/material.dart';
import 'package:sachet/pages/utilspages/zhengfang_jwxt_login_page.dart';

class LoginExpiredZF extends StatelessWidget {
  /// 登录失效，登录过期（正方教务系统）
  const LoginExpiredZF({
    super.key,
    this.onGoBack, // 从登录页面返回后回调的函数
  }) : isCompact = false;

  /// Compact 版本（更紧凑，适合空间有限的区域）
  const LoginExpiredZF.compact({
    super.key,
    this.onGoBack,
  }) : isCompact = true;

  final Function? onGoBack;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: isCompact ? 20.0 : 40.0,
                horizontal: isCompact ? 16.0 : 24.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isCompact ? 20.0 : 28.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isCompact ? 48 : 80,
                    height: isCompact ? 48 : 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(isCompact ? 16.0 : 24.0),
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
                        horizontal: isCompact ? 16 : 24,
                        vertical: isCompact ? 6 : 8,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const ZhengFangJwxtLoginPage();
                          },
                        ),
                      ).then((value) {
                        var onGoBackFunc = onGoBack;
                        if (onGoBackFunc != null) {
                          onGoBackFunc(value);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.login,
                      size: isCompact ? 16 : 18,
                      applyTextScaling: true,
                    ),
                    label: const Text('重新登录'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
