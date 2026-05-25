import 'package:flutter/material.dart';
import 'package:sachet/widgets/utils_widgets/data_from_cache_or_http.dart';

class CultivationPlanOldDataPage extends StatefulWidget {
  /// 查看之前从旧教务系统（强智教务系统）获取培养方案缓存的数据。
  /// 本应用不再支持从旧教务系统（强智教务系统）获取培养方案，只支持查看旧的缓存数据。
  const CultivationPlanOldDataPage({
    super.key,
    required this.data,
    required this.updateTime,
  });
  final List data;
  final String updateTime;

  @override
  State<CultivationPlanOldDataPage> createState() =>
      _CultivationPlanOldDataPageState();
}

class _CultivationPlanOldDataPageState
    extends State<CultivationPlanOldDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: const Text('培养方案')),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            sliver: SliverToBoxAdapter(
              child: SelectionArea(
                child: _CultivationPlanTable(
                  data: widget.data,
                  updateTime: widget.updateTime,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CultivationPlanTable extends StatefulWidget {
  const _CultivationPlanTable({
    super.key,
    required this.data,
    required this.updateTime,
  });
  final List data;
  final String updateTime;

  @override
  State<_CultivationPlanTable> createState() => _CultivationPlanTableState();
}

class _CultivationPlanTableState extends State<_CultivationPlanTable> {
  final List<String> tableHead = [
    '序号',
    '开设学期',
    '课程名称',
    '课程类别',
    '总学时',
    '学分',
    '考核方式',
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(7),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(2),
            6: FlexColumnWidth(2),
          },
          // defaultColumnWidth: FractionColumnWidth(0.17),
          border: TableBorder.all(color: colorScheme.onSurfaceVariant),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(color: colorScheme.primaryContainer),
              children: [
                ...List.generate(
                  7,
                  (index) => TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        tableHead[index],
                        style: textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onPrimaryContainer),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...List.generate(
              widget.data.length,
              (curriculumIndex) => TableRow(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                ),
                children: [
                  ...List.generate(
                    7,
                    (itemIndex) => TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          widget.data[curriculumIndex]?.entries
                              .elementAt(itemIndex)
                              .value,
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: DataFromCacheOrHttp(
            useCache: true,
            updataTime: widget.updateTime,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
