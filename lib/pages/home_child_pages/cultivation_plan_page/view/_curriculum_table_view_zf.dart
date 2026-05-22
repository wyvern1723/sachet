import 'package:flutter/material.dart';
import 'package:sachet/models/zhengfang_jwxt/response/curriculum_response_zf.dart';
import 'package:sachet/widgets/homepage_widgets/cultivation_page_zf_widgets/curriculum_data_table.dart';

class CurriculumTableViewZF extends StatelessWidget {
  const CurriculumTableViewZF({
    super.key,
    required this.curriculums,
    required this.footer,
  });
  final List<CurriculumResponseZF> curriculums;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurriculumDataTable(curriculums: curriculums),
                footer,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
