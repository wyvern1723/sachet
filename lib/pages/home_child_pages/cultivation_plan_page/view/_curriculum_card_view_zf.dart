import 'package:flutter/material.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/models/curriculum_response_zf.dart';
import 'package:sachet/widgets/homepage_widgets/cultivation_page_zf_widgets/curriculum_card.dart';

abstract class _FlatItem {}

// 学期标题
class _HeaderItem extends _FlatItem {
  final String semesterKey;
  final String titleText;
  final int count;

  _HeaderItem({
    required this.semesterKey,
    required this.titleText,
    required this.count,
  });
}

// 单个课程卡片
class _CourseItem extends _FlatItem {
  final CurriculumResponseZF curriculum;
  final int indexInSemester;

  _CourseItem({
    required this.curriculum,
    required this.indexInSemester,
  });
}

// 页脚
class _FooterItem extends _FlatItem {}

class CurriculumCardViewZF extends StatefulWidget {
  const CurriculumCardViewZF({
    super.key,
    required this.curriculums,
    required this.footer,
  });

  final List<CurriculumResponseZF> curriculums;
  final Widget footer;

  @override
  State<CurriculumCardViewZF> createState() => _CurriculumCardViewZFState();
}

class _CurriculumCardViewZFState extends State<CurriculumCardViewZF>
    with AutomaticKeepAliveClientMixin {
  late Map<String, List<CurriculumResponseZF>> _groupedCurriculums;

  final Set<String> _collapsedSemesters = {};

  List<_FlatItem> _flatItems = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _groupAndFlatten();
  }

  @override
  void didUpdateWidget(covariant CurriculumCardViewZF oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curriculums != widget.curriculums) {
      _groupAndFlatten();
    }
  }

  void _groupAndFlatten() {
    final Map<String, List<CurriculumResponseZF>> grouped = {};
    for (final curriculum in widget.curriculums) {
      final key = curriculum.yyxdxnxqmc ?? '';
      grouped.putIfAbsent(key, () => []).add(curriculum);
    }
    _groupedCurriculums = grouped;
    _rebuildFlatItems();
  }

  void _rebuildFlatItems() {
    final List<_FlatItem> items = [];

    _groupedCurriculums.forEach((semesterKey, semesterCurriculums) {
      if (semesterCurriculums.isEmpty) return;

      final academicYear = semesterCurriculums.first.jyxdxnm ?? '';
      final rawTerm = semesterCurriculums.first.jyxdxqm ?? '';
      final displayTerm = rawTerm == '1'
          ? '一'
          : rawTerm == '2'
              ? '二'
              : rawTerm;

      final String titleText = '$academicYear 学年 · 第$displayTerm学期';

      items.add(_HeaderItem(
        semesterKey: semesterKey,
        titleText: titleText,
        count: semesterCurriculums.length,
      ));

      if (!_collapsedSemesters.contains(semesterKey)) {
        for (int i = 0; i < semesterCurriculums.length; i++) {
          items.add(_CourseItem(
            curriculum: semesterCurriculums[i],
            indexInSemester: i + 1,
          ));
        }
      }
    });

    items.add(_FooterItem());

    setState(() {
      _flatItems = items;
    });
  }

  // 展开或收起学期
  void _toggleSemester(String semesterKey) {
    if (_collapsedSemesters.contains(semesterKey)) {
      _collapsedSemesters.remove(semesterKey);
    } else {
      _collapsedSemesters.add(semesterKey);
    }
    _rebuildFlatItems();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SelectionArea(
      child: CustomScrollView(
        cacheExtent: 1000,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            sliver: SliverList.builder(
              itemCount: _flatItems.length,
              itemBuilder: (context, index) {
                final item = _flatItems[index];

                // 学期标题
                if (item is _HeaderItem) {
                  final isExpanded =
                      !_collapsedSemesters.contains(item.semesterKey);
                  return _SemesterHeaderTile(
                    key: ValueKey(item.semesterKey),
                    titleText: item.titleText,
                    count: item.count,
                    isExpanded: isExpanded,
                    onTap: () => _toggleSemester(item.semesterKey),
                  );
                }

                // 课程
                if (item is _CourseItem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    child: CurriculumCard(
                      curriculum: item.curriculum,
                      indexInSemester: item.indexInSemester,
                    ),
                  );
                }

                // 页脚
                if (item is _FooterItem) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 20.0),
                    child: widget.footer,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterHeaderTile extends StatelessWidget {
  const _SemesterHeaderTile({
    super.key,
    required this.titleText,
    required this.count,
    required this.isExpanded,
    required this.onTap,
  });

  final String titleText;
  final int count;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _SemesterTitle(
                text: titleText,
                semesterCurriculumsLength: count,
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 学期标题文字
class _SemesterTitle extends StatelessWidget {
  const _SemesterTitle({
    required this.text,
    required this.semesterCurriculumsLength,
  });

  final String text;
  final int semesterCurriculumsLength;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(left: 8.0),
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
