import 'package:flutter/material.dart';
import 'package:sachet/models/zhengfang_jwxt/response/curriculum_response_zf.dart';
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
    int i = 1;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              child: SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(curriculums.length, (index) {
                      if (index == 0 ||
                          curriculums[index].yyxdxnxqmc !=
                              curriculums[index - 1].yyxdxnxqmc) {
                        i = 1;
                        return Column(
                          children: [
                            _semesterTitle(
                              context,
                              '${curriculums[index].jyxdxnm} 学年 · 第${curriculums[index].jyxdxqm == '1' ? '一' : curriculums[index].jyxdxqm == '2' ? '二' : curriculums[index].jyxdxqm}学期',
                            ),
                            CurriculumCard(
                              curriculum: curriculums[index],
                              indexInSemester: i,
                            ),
                          ],
                        );
                      }
                      i = i + 1;
                      return CurriculumCard(
                        curriculum: curriculums[index],
                        indexInSemester: i,
                      );
                    }),
                    footer,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _semesterTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 4.0),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
            applyTextScaling: true,
          ),
          SizedBox(width: 8.0),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          )
        ],
      ),
    );
  }
}
