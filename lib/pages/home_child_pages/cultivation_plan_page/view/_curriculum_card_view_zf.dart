import 'package:flutter/material.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/models/curriculum_response_zf.dart';
import 'package:sachet/widgets/homepage_widgets/cultivation_page_zf_widgets/curriculum_card.dart';

class CurriculumCardViewZF extends StatelessWidget {
  const CurriculumCardViewZF({
    super.key,
    required this.curriculums,
    required this.footer,
  });
  final List<CurriculumResponseZF> curriculums;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    // Group curriculums by semester
    final Map<String, List<CurriculumResponseZF>> groupedCurriculums = {};
    for (final curriculum in curriculums) {
      final key = curriculum.yyxdxnxqmc ?? '';
      groupedCurriculums.putIfAbsent(key, () => []).add(curriculum);
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          sliver: SliverToBoxAdapter(
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...groupedCurriculums.entries.map((entry) {
                    // final semesterName = entry.key;
                    final semesterCurriculums = entry.value;

                    if (semesterCurriculums.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final academicYear =
                        semesterCurriculums.first.jyxdxnm ?? '';
                    final rawTerm = semesterCurriculums.first.jyxdxqm ?? '';
                    final displayTerm = rawTerm == '1'
                        ? '一'
                        : rawTerm == '2'
                            ? '二'
                            : rawTerm;

                    final String titleText =
                        '$academicYear 学年 · 第$displayTerm学期';

                    return Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: _semesterTitle(
                          titleText,
                          semesterCurriculums.length,
                          context,
                        ),
                        tilePadding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        childrenPadding: const EdgeInsets.symmetric(
                          vertical: 0.0,
                          horizontal: 8.0,
                        ),
                        expandedAlignment: Alignment.topLeft,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          semesterCurriculums.length,
                          (index) => CurriculumCard(
                            curriculum: semesterCurriculums[index],
                            indexInSemester: index + 1,
                          ),
                        ),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 20.0),
                    child: footer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _semesterTitle(
    String text,
    int semesterCurriculumsLength,
    BuildContext context,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 14,
          color: colorScheme.primary,
          applyTextScaling: true,
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            text,
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Text(
            '($semesterCurriculumsLength门课程)',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
