import 'package:flutter/material.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/models/curriculum_response_zf.dart';
import 'package:sachet/widgets/homepage_widgets/cultivation_page_zf_widgets/curriculum_data_table.dart';

class CurriculumTableViewZF extends StatefulWidget {
  const CurriculumTableViewZF({
    super.key,
    required this.curriculums,
    required this.footer,
  });
  final List<CurriculumResponseZF> curriculums;
  final Widget footer;

  @override
  State<CurriculumTableViewZF> createState() => _CurriculumTableViewZFState();
}

class _CurriculumTableViewZFState extends State<CurriculumTableViewZF>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurriculumDataTable(curriculums: widget.curriculums),
                widget.footer,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
