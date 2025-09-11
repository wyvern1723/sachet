import 'package:flutter/material.dart';
import 'package:sachet/models/free_classroom_data_zf.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_widgets/item_filter_dialog.dart';

class FreeClassroomResultPageZF extends StatefulWidget {
  const FreeClassroomResultPageZF({
    super.key,
    required this.listData,
    required this.onFiltering,
  });
  final List<FreeClassroomDataZF> listData;
  final VoidCallback onFiltering;

  @override
  State<FreeClassroomResultPageZF> createState() =>
      _FreeClassroomResultPageZFState();
}

class _FreeClassroomResultPageZFState extends State<FreeClassroomResultPageZF> {
  List<String> _items = [
    '楼号',
    '场地名称',
    '场地类别',
    '场地二级类别',
    '座位数',
    '考试座位数',
  ];

  List<String> _selectedItems = [
    '楼号',
    '场地名称',
  ];

  Future showFilterDialog() async {
    List<List<String>>? results = await showDialog(
      context: context,
      builder: (BuildContext context) => ItemFilterDialog(
        items: _items,
        selectedItems: _selectedItems,
      ),
    );
    if (results != null) {
      // 新选择要展示的 SelectedItems，（经过 List.add、List.remove,顺序会很乱）
      List<String> newSelectedItems = results[0];

      // （可能）经过重新排序的 Items
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  await showFilterDialog();
                },
                icon: Icon(Icons.filter_list_outlined),
                label: Text('显示字段'),
              ),
            ],
          ),
          if (_selectedItems.isNotEmpty)
            Table(
              columnWidths: <int, TableColumnWidth>{
                _selectedItems.indexOf('楼号'): FlexColumnWidth(4),
                _selectedItems.indexOf('场地名称'): FlexColumnWidth(7),
                _selectedItems.indexOf('座位数'): FlexColumnWidth(2),
                _selectedItems.indexOf('考试座位数'): FlexColumnWidth(2),
                _selectedItems.indexOf('场地类别'): FlexColumnWidth(4),
                _selectedItems.indexOf('场地二级类别'): FlexColumnWidth(4),
              },
              defaultColumnWidth: FlexColumnWidth(2),
              border: TableBorder.all(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  children: List.generate(
                    _selectedItems.length,
                    (index) => TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          _selectedItems[index],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                ...widget.listData.map(
                  (freeClassroom) => TableRow(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    children: [
                      ..._selectedItems.map(
                        (selectedItem) => TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 4.0),
                            child: Text(freeClassroom.item(selectedItem),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '共 ${widget.listData.length} 条',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
