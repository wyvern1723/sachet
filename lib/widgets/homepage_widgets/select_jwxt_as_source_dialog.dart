import 'package:flutter/material.dart';
import 'package:sachet/models/jwxt_type.dart';

class SelectJwxtAsSourceDialog extends StatelessWidget {
  /// 选择哪个教务系统作为数据来源的 Dialog
  const SelectJwxtAsSourceDialog({super.key, required this.title});

  /// Dialog 标题
  final String title;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      contentPadding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 24.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.pop(
                context, JwxtType.zhengfang), // 关掉这个 Dialog，返回 jwxtType
            child: Ink(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 教务系统描述
                  Text(
                    JwxtType.zhengfang.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold),
                  ),

                  // 教务系统链接 (小字提示)
                  Text(
                    '(${JwxtType.zhengfang.baseUrl})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.pop(
                context, JwxtType.qiangzhi), // 关掉这个 Dialog，返回 jwxtType
            child: Ink(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 教务系统描述
                  Text(
                    JwxtType.qiangzhi.description,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  // 教务系统链接 (小字提示)
                  Text(
                    '(${JwxtType.qiangzhi.baseUrl})  ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
