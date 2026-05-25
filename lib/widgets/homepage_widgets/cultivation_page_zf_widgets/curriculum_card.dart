import 'package:flutter/material.dart';
import 'package:sachet/models/zhengfang_jwxt/response/curriculum_response_zf.dart';

class CurriculumCard extends StatefulWidget {
  /// 培养方案课程信息卡片
  const CurriculumCard({
    super.key,
    required this.curriculum,
    required this.indexInSemester,
  });
  final CurriculumResponseZF curriculum;
  final int indexInSemester;

  @override
  State<CurriculumCard> createState() => _CurriculumCardState();
}

class _CurriculumCardState extends State<CurriculumCard> {
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final curriculum = widget.curriculum;

    /// 课程名称
    final title = curriculum.kcmc ?? '';

    /// 课程英文名称
    final englishTitle = curriculum.kcywmc;

    /// 学分
    final credits = curriculum.xf == null ? '' : curriculum.xf.toString();

    /// 总学时
    final totalHours =
        curriculum.xsdm01 == null ? '' : '${curriculum.xsdm01.toString()} 学时';
    final teachingSchool = curriculum.kkbmmc ?? '';
    final assessmentMethod = curriculum.khfsdm ?? '';

    /// 课程性质
    // final courseType = curriculum.kcxzmc ?? '';

    /// 课程类别
    // final courseCategory = curriculum.kclbmc ?? '';

    /// 修读要求节点
    final courseModule = curriculum.xfyqjdmc ?? '';

    final semester = curriculum.yyxdxnxqmc ?? '';

    final TextStyle? titleTextStyle = textTheme.titleMedium?.copyWith();
    final TextStyle? englishTitleTextStyle =
        textTheme.labelSmall?.copyWith(color: colorScheme.outline);
    final TextStyle? totalHoursTextStyle = textTheme.bodySmall
        ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10);
    final TextStyle? teachingSchoolTextStyle =
        textTheme.bodySmall?.copyWith(color: colorScheme.outline, fontSize: 10);

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
                            radius: MediaQuery.textScalerOf(context).scale(10),
                            backgroundColor:
                                colorScheme.primaryContainer.withOpacity(0.4),
                            child: Text(
                              widget.indexInSemester.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                          ),
                          SizedBox(width: 8.0),
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
                                TextSpan(text: ' 学分'),
                              ],
                            ),
                          ),
                          Text(totalHours, style: totalHoursTextStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.textScalerOf(context).scale(24),
                  ),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: [
                      // _buildBadge(context, courseType),
                      _buildBadge(context, courseModule),
                      // _buildBadge(context, courseCategory),
                      _buildBadge(context, assessmentMethod),
                    ],
                  ),
                ),
                Divider(
                  indent: MediaQuery.textScalerOf(context).scale(24),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.textScalerOf(context).scale(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: MediaQuery.textScalerOf(context).scale(12),
                              color: colorScheme.outline,
                            ),
                            SizedBox(width: 4.0),
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

  Widget _buildBadge(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: text == '考试'
            ? colorScheme.secondaryContainer
            : text == '考查'
                ? colorScheme.secondaryContainer
                : colorScheme.secondaryContainer,
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
