import 'package:flutter/material.dart';
import 'package:sachet/models/jwxt_type.dart';
import 'package:sachet/pages/utilspages/qiangzhi_jwxt_login_page.dart';
import 'package:sachet/pages/utilspages/zhengfang_jwxt_login_page.dart';

class SelectJwxtLoginDialog extends StatelessWidget {
  /// 选择哪个教务系统来登录的 Dialog
  const SelectJwxtLoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("选择要登录的教务系统"),
      contentPadding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 40.0),
      children: JwxtType.values
          .map(
            (e) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pop(context); // 关掉这个 Dialog
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        switch (e) {
                          case JwxtType.qiangzhi:
                            return const QiangZhiJwxtLoginPage();
                          case JwxtType.zhengfang:
                            return const ZhengFangJwxtLoginPage();
                        }
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 教务系统描述
                      Text(
                        '${e.description} (${e.label})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // 教务系统链接 (小字提示)
                      Text(
                        '(${e.baseUrl.replaceFirst('', '')})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
