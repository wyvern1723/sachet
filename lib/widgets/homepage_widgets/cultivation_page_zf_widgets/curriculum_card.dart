import 'package:flutter/material.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/models/curriculum_response_zf.dart';

class CurriculumCard extends StatelessWidget {
  /// 培养方案课程信息卡片
  const CurriculumCard({
    super.key,
    required this.curriculum,
    required this.indexInSemester,
  });

  final CurriculumResponseZF curriculum;
  final int indexInSemester;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    /// 课程名称
    final title = curriculum.kcmc ?? '';

    /// 课程英文名称
    final englishTitle = curriculum.kcywmc;

    /// 学分
    final credits = curriculum.xf == null ? '' : curriculum.xf.toString();

    /// 总学时
    final totalHours =
        curriculum.xsdm01 == null ? '' : '${curriculum.xsdm01} 学时';
    final teachingSchool = curriculum.kkbmmc ?? '';
    final assessmentMethod = curriculum.khfsdm ?? '';

    /// 课程性质
    // final courseType = curriculum.kcxzmc ?? '';

    /// 课程类别
    // final courseCategory = curriculum.kclbmc ?? '';

    /// 修读要求节点
    final courseModule = curriculum.xfyqjdmc ?? '';

    final semester = curriculum.yyxdxnxqmc ?? '';

    final TextStyle? titleTextStyle = textTheme.titleMedium;
    final TextStyle? englishTitleTextStyle =
        textTheme.labelSmall?.copyWith(color: colorScheme.outline);
    final TextStyle? totalHoursTextStyle = textTheme.bodySmall
        ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10);
    final TextStyle? teachingSchoolTextStyle =
        textTheme.bodySmall?.copyWith(color: colorScheme.outline, fontSize: 10);

    final double scaledLeftIndent = textScaler.scale(24);

    return Card(
      clipBehavior: Clip.antiAlias,
      // elevation: 0.0,
      // color: colorScheme.surfaceContainer.withOpacity(0.85),
      elevation: 1.0,
      // color: colorScheme.surfaceContainerLow,
      // color: colorScheme.secondaryContainer.withOpacity(0.9),
      // color: colorScheme.primaryContainer,
      color: Color.lerp(
        colorScheme.surfaceContainerLow,
        colorScheme.primaryContainer.withOpacity(0.6),
        0.16,
      )?.withOpacity(0.9),
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: textScaler.scale(10),
                            backgroundColor:
                                colorScheme.primaryContainer.withOpacity(0.4),
                            child: Text(
                              indexInSemester.toString(),
                              style: textTheme.labelLarge
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(title, style: titleTextStyle),
                                if (englishTitle != null)
                                  Text(
                                    englishTitle,
                                    style: englishTitleTextStyle,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: credits,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const TextSpan(text: ' 学分'),
                              ],
                            ),
                          ),
                          Text(totalHours, style: totalHoursTextStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: scaledLeftIndent),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: [
                      // _Badge(context, courseType),
                      _Badge(text: courseModule),
                      // _Badge(context, courseCategory),
                      _Badge(text: assessmentMethod),
                    ],
                  ),
                ),
                Divider(
                  indent: scaledLeftIndent,
                ),
                Padding(
                  padding: EdgeInsets.only(left: scaledLeftIndent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: textScaler.scale(12),
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4.0),
                            Flexible(
                              child: Text(
                                teachingSchool,
                                style: teachingSchoolTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          semester,
                          style: teachingSchoolTextStyle,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
