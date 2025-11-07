import 'package:flutter/material.dart';
import 'package:sachet/models/grade_zf.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_qz_widgets/item_filter_dialog.dart';

class GradeTableZF extends StatefulWidget {
  /// 成绩查询界面（正方教务）的成绩信息表
  const GradeTableZF({super.key, required this.gradeData});
  final List<GradeZf> gradeData;

  @override
  State<GradeTableZF> createState() => _GradeTableZFState();
}

class _GradeTableZFState extends State<GradeTableZF> {
  List<String> _items = ['学期', '课程名称', '任课教师', '学分', '成绩', '绩点', '课程性质'];
  List<String> _selectedItems = ['课程名称', '学分', '成绩'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: showFilterDialog,
              icon: Icon(Icons.filter_list_outlined),
              label: Text('筛选'),
            ),
          ],
        ),
        if (_selectedItems.isNotEmpty)
          Table(
            columnWidths: <int, TableColumnWidth>{
              _selectedItems.indexOf('课程名称'): FlexColumnWidth(7),
              _selectedItems.indexOf('学期'): FlexColumnWidth(5),
              _selectedItems.indexOf('任课教师'): FlexColumnWidth(4),
              _selectedItems.indexOf('课程性质'): FlexColumnWidth(6),
            },
            defaultColumnWidth: FlexColumnWidth(2),
            border: TableBorder.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                children: List.generate(
                  _selectedItems.length,
                  (index) => TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        _selectedItems[index],
                        textAlign: _selectedItems[index] == '课程名称'
                            ? TextAlign.start
                            : TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              ...List.generate(
                widget.gradeData.length,
                (index) => TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                  children: [
                    ..._selectedItems.map(
                      (e) => TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Text(
                            widget.gradeData[index].item(e),
                            textAlign: e == '课程名称'
                                ? TextAlign.start
                                : TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void showFilterDialog() async {
    List<List<String>>? results = await showDialog(
      context: context,
      builder: (BuildContext context) => ItemFilterDialogQZ(
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
}
