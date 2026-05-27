import 'package:flutter/material.dart';
import 'package:sachet/services/zhengfang_jwxt/cultivation/models/curriculum_response_zf.dart';
import 'package:sachet/utils/utils_functions.dart';
import 'package:sachet/widgets/homepage_widgets/utils_widgets/item_filter_dialog.dart';

class CurriculumDataTable extends StatefulWidget {
  /// 培养方案课程信息表格
  const CurriculumDataTable({
    super.key,
    required this.curriculums,
    this.footer,
  });
  final List<CurriculumResponseZF> curriculums;
  final Widget? footer;

  @override
  State<CurriculumDataTable> createState() => _CurriculumDataTableState();
}

class _CurriculumDataTableState extends State<CurriculumDataTable> {
  late final ScrollController _horizontalController;

  List<String> copyableItems = ['课程名称', '课程英文名称'];
  List<String> centerItems = ['课程名称', '课程英文名称', '序号'];

  List<String> _items = [
    '序号',
    '学年',
    '学期',
    '学年学期',
    '课程名称',
    '课程英文名称',
    '学分',
    '总学时',
    '课程性质',
    '课程类别',
    '考核方式',
    '修读要求节点',
    '开课部门',
  ];

  List<String> _selectedItems = [
    '序号',
    '学年学期',
    '课程名称',
    '学分',
    '总学时',
    '课程性质',
    '考核方式',
  ];

  Future showFilterDialog(BuildContext context) async {
    List<List<String>>? results = await showDialog(
      context: context,
      builder: (BuildContext context) => ItemFilterDialog(
        items: _items,
        selectedItems: _selectedItems,
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (results != null) {
      // 新选择的要显示的 selectedItems，（经过 List.add、List.remove,顺序会乱）
      List<String> newSelectedItems = results[0];

      // （可能）经过重新排序的 items
      List<String> reorderedItems = results[1];

      // 对 newSelectedItems 根据 reorderedItems 的顺序排序
      // e.g.
      // newSelectedItems = [[课程名称, 学分, 平时成绩, 总成绩, 考核方式, 期末成绩],
      // reorderedItems = [开课学期, 课程名称, 学分, 平时成绩, 期末成绩, 总成绩, 总学时, 考核方式, 课程属性, 课程性质]]
      // 经过下面的处理 ==>
      // newSelectedItems = [课程名称, 学分, 平时成绩, 期末成绩, 总成绩, 考核方式]
      newSelectedItems.sort((a, b) =>
          reorderedItems.indexOf(a).compareTo(reorderedItems.indexOf(b)));
      setState(() {
        _selectedItems = newSelectedItems;
        _items = reorderedItems;
      });
    }
  }

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 4.0, 4.0),
          child: Row(
            children: [
              Text('课程信息：', style: textTheme.titleMedium),
              Spacer(),
              IconButton(
                tooltip: '复制为 Markdown 表格',
                onPressed: () {
                  final buffer = StringBuffer();

                  String tableHead = '| ${_selectedItems.join(' | ')} |';
                  buffer.write(tableHead);
                  buffer.write('\n');

                  List dashList = [];
                  for (final item in _selectedItems) {
                    dashList
                        .add(copyableItems.contains(item) ? ':---' : ':---:');
                  }
                  String tableSecondLine = '| ${dashList.join(' | ')} |';
                  buffer.write(tableSecondLine);
                  buffer.write('\n');

                  for (final (index, curriculum)
                      in widget.curriculums.indexed) {
                    final singleCurriculumStringBuffer = StringBuffer();
                    List text = [];
                    for (final item in _selectedItems) {
                      text.add(
                        item == '序号'
                            ? (index + 1).toString()
                            : curriculum.item(item).toString(),
                      );
                    }
                    singleCurriculumStringBuffer
                        .write('| ${text.join(' | ')} |');
                    singleCurriculumStringBuffer.write('\n');
                    buffer.write(singleCurriculumStringBuffer);
                  }

                  final text = buffer.toString();

                  copyToClipboard(context, text);
                },
                icon: Icon(Icons.copy),
                iconSize: 20,
                splashRadius: 24,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () async {
                  await showFilterDialog(context);
                },
                icon: Icon(Icons.filter_list_outlined),
                tooltip: '筛选',
                splashRadius: 24,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            trackVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SelectionArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _dataTable(colorScheme, textTheme),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.footer != null) widget.footer!,
      ],
    );
  }

  Widget _dataTable(ColorScheme colorScheme, TextTheme textTheme) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        colorScheme.surfaceContainerHighest.withOpacity(0.5),
      ),
      columns: [
        ..._selectedItems.map(
          (e) => e == '序号'
              ? DataColumn(
                  label: Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '#',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                  ),
                )
              : DataColumn(
                  label: Expanded(
                    child: Align(
                      alignment: copyableItems.contains(e)
                          ? Alignment.centerLeft
                          : Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          e,
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
      rows: <DataRow>[
        ...List.generate(widget.curriculums.length, (index) {
          final e = widget.curriculums[index];
          return DataRow(
            cells: <DataCell>[
              for (final item in _selectedItems)
                item == '序号'
                    ? DataCell(
                        Center(
                          child: Text(
                            ' ${(index + 1)} ',
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        ),
                      )
                    : e.item(item) == null
                        ? DataCell(SizedBox.shrink())
                        : copyableItems.contains(item)
                            ? _copyableDataCell(
                                e.item(item).toString(), context,
                                tapToCopy: true)
                            : DataCell(
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Text(e.item(item).toString()),
                                  ),
                                ),
                              ),
            ],
          );
        })
      ],
      horizontalMargin: 8,
      columnSpacing: 8,
      dataRowMaxHeight: double.infinity,
      headingTextStyle: textTheme.labelMedium,
      dataTextStyle: textTheme.bodySmall,
      dataRowMinHeight: 0,
      headingRowHeight: MediaQuery.textScalerOf(context).scale(24),
    );
  }

  DataCell _copyableDataCell(String text, BuildContext context,
      {bool tapToCopy = false}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth > 500 ? 200.0 : screenWidth * 0.4;
    return DataCell(
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(text),
        ),
      ),
      onTap: tapToCopy ? () => copyToClipboard(context, text) : null,
    );
  }
}
