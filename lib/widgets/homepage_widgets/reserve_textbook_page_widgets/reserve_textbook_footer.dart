import 'package:flutter/material.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/utils/utils_functions.dart';

class ReserveTextbookFooter extends StatelessWidget {
  final String queryingSemesterYear;
  final String queryingSemesterIndex;

  const ReserveTextbookFooter({
    super.key,
    required this.queryingSemesterYear,
    required this.queryingSemesterIndex,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final textStyle = textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.outline,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示当前查询的学期
        Text(
          '当前查询学期: $queryingSemesterYear-$queryingSemesterIndex',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2),
        Text('本软件只提供查询，不实现提交信息的功能', style: textStyle),
        Wrap(children: [
          Text('如需预订教材，请在', style: textStyle),
          GestureDetector(
            onTap: () => openLink(newJwxtBaseUrl),
            onLongPress: () =>
                copyToClipboard(context, newJwxtBaseUrl, prefix: '链接'),
            child: Text(
              '教务系统官网',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFF0645AD)
                    : Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF0645AD)
                        : Colors.blue,
                fontSize: 12.0,
              ),
            ),
          ),
          Text('预订', style: textStyle),
        ]),
      ],
    );
  }
}
