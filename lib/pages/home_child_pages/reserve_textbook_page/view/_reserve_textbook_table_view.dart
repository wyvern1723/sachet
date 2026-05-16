import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/models/zhengfang_jwxt/response/reserve_textbook_response_zf.dart';
import 'package:sachet/widgets/homepage_widgets/utils_widgets/item_filter_dialog.dart';

class ReserveTextbookTableView extends StatefulWidget {
  /// 表格格式
  const ReserveTextbookTableView({
    super.key,
    required this.bookData,
    this.footer,
  });
  final List<ReserveTextbookResponseZF> bookData;
  final Widget? footer;

  @override
  State<ReserveTextbookTableView> createState() =>
      _ReserveTextbookTableViewState();
}

class _ReserveTextbookTableViewState extends State<ReserveTextbookTableView> {
  late final ScrollController _horizontalController;

  List<String> copyableItems = [
    '课程名称',
    '教材名称',
    'ISBN',
    '教材作者',
    '出版社',
    '版本号',
  ];

  List<String> _items = [
    '学年',
    '学期',
    '课程名称',
    '教材名称',
    'ISBN',
    '教材作者',
    '出版社',
    '版本号',
    '出版日期',
    '单价',
    '课程性质',
    '任课教师',
  ];

  List<String> _selectedItems = [
    '课程名称',
    '教材名称',
    'ISBN',
    '教材作者',
    '出版社',
    '版本号',
    '出版日期',
    '单价',
    '课程性质',
    '任课教师',
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('教材信息：', style: Theme.of(context).textTheme.titleMedium),
              Spacer(),
              IconButton(
                onPressed: () async {
                  await showFilterDialog(context);
                },
                icon: Icon(Icons.filter_list_outlined),
                tooltip: '筛选',
                splashRadius: 24,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: '复制为 Markdown 表格',
                onPressed: () {
                  final buffer = StringBuffer();

                  String tableHead = '| 序号 | ${_selectedItems.join(' | ')} |';
                  buffer.write(tableHead);
                  buffer.write('\n');

                  List dashList = [];
                  for (final item in _selectedItems) {
                    dashList
                        .add(copyableItems.contains(item) ? ':--' : ':---:');
                  }
                  String tableSecondLine = '| --- | ${dashList.join(' | ')} |';
                  buffer.write(tableSecondLine);
                  buffer.write('\n');

                  for (final (index, book) in widget.bookData.indexed) {
                    final singleBookStringBuffer = StringBuffer();
                    singleBookStringBuffer.write('| $index ');
                    List text = [];
                    for (final item in _selectedItems) {
                      text.add(book.item(item).toString());
                    }
                    singleBookStringBuffer.write('| ${text.join(' | ')} |');
                    singleBookStringBuffer.write('\n');
                    buffer.write(singleBookStringBuffer);
                  }

                  final text = buffer.toString();

                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
                icon: Icon(Icons.copy),
                iconSize: 20,
                splashRadius: 24,
                visualDensity: VisualDensity.compact,
              ),
            ],
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
                  child: DataTable(
                    columns: [
                      ...[
                        '', // 第一列：序号
                        ..._selectedItems // 其他选择展示信息的列
                      ].map(
                        (e) => DataColumn(
                          label: Expanded(
                            child: Align(
                              alignment: copyableItems.contains(e)
                                  ? Alignment.centerLeft
                                  : Alignment.center,
                              child: Text(e),
                            ),
                          ),
                        ),
                      )
                    ],
                    rows: <DataRow>[
                      ...List.generate(widget.bookData.length, (index) {
                        final e = widget.bookData[index];
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(' ${(index + 1)} ')), // 第一列：序号
                            for (final item in _selectedItems)
                              copyableItems.contains(item)
                                  ? copyableDataCell(
                                      e.item(item).toString(), context)
                                  : DataCell(Center(
                                      child: Text(e.item(item).toString()))),
                          ],
                        );
                      })
                    ],
                    horizontalMargin: 4,
                    columnSpacing: 8,
                    dataRowMaxHeight: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }

  DataCell copyableDataCell(String text, BuildContext context,
      {bool tapToCopy = false}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth > 500 ? 200.0 : screenWidth * 0.4;
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(text),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            icon: Icon(Icons.content_copy),
            iconSize: 14,
            padding: EdgeInsets.all(0),
            visualDensity: VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
            splashRadius: 16,
          ),
        ],
      ),
      onTap: tapToCopy
          ? () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已复制到剪贴板')),
              );
            }
          : null,
    );
  }
}
