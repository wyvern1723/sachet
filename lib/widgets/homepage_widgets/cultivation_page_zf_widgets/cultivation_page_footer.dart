import 'package:flutter/material.dart';

class CultivationPageFooter extends StatelessWidget {
  final String queryingGrade;
  final String queryingSchool;
  final String queryingMajor;
  final String queryingQueryMajor;

  const CultivationPageFooter({
    super.key,
    required this.queryingGrade,
    required this.queryingSchool,
    required this.queryingMajor,
    required this.queryingQueryMajor,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Text(
      '当前查询: $queryingGrade-$queryingSchool-$queryingMajor-$queryingQueryMajor',
      style: textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
