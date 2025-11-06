import 'package:flutter/material.dart';
import 'package:sachet/models/jwxt_type.dart';

class SelectJwxtAsGradeSourceDialog extends StatelessWidget {
  /// 选择哪个教务系统作为成绩数据来源的 Dialog
  const SelectJwxtAsGradeSourceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("选择成绩数据来源"),
      contentPadding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 24.0),
      children: JwxtType.values
          .map(
            (e) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pop(context, e); // 关掉这个 Dialog，返回 jwxtType
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // 教务系统链接 (小字提示)
                      Text(
                        '(${e.baseUrl})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline),
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
