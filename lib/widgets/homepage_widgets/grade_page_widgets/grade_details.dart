import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/grade_page_provider.dart';
import '../../utils_widgets/login_expired_qz.dart';
import 'item_filter_dialog.dart';

class GradeDetails extends StatefulWidget {
  /// 成绩信息详细表
  const GradeDetails({
    super.key,
  });

  @override
  State<GradeDetails> createState() => _GradeDetailsState();
}

class _GradeDetailsState extends State<GradeDetails> {
  @override
  Widget build(BuildContext context) {
    context.select<GradePageProvider, String>(
        (gradePageProvider) => (gradePageProvider.semester)); // 监听 semester 变化
    return FutureBuilder(
        future: context.read<GradePageProvider>().getExamScoresDetailsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              if (snapshot.error == '登录失效，请重新登录') {
                return LoginExpiredQZ();
              } else if (snapshot.error == '评教未完成，不能查询成绩。请先完成评教。') {
                return Text(
                  '评教未完成，不能查询成绩。请先完成评教。',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  ),
                );
              } else {
                return Text('${snapshot.error}');
              }
            } else {
              return GradeDetailsTable(listData: snapshot.data ?? []);
            }
          } else {
            return Column(
              children: [
                SizedBox(height: 20),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
        });
  }
}

class GradeDetailsTable extends StatefulWidget {
  /// 成绩信息详细界面的信息表
  const GradeDetailsTable({super.key, required this.listData});
  final List listData;

  @override
  State<GradeDetailsTable> createState() => _GradeDetailsTableState();
}

class _GradeDetailsTableState extends State<GradeDetailsTable> {
  List<String> _items = [
    '开课学期',
    '课程名称',
    '学分',
    '平时成绩',
    '期末成绩',
    '总成绩',
    '总学时',
    '考核方式',
    '课程属性',
    '课程性质'
  ];
  List<String> _selectedItems = [
    // '开课学期',
    '课程名称',
    '学分',
    '平时成绩',
    '总成绩',
  ];

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
              _selectedItems.indexOf('开课学期'): FlexColumnWidth(5),
              _selectedItems.indexOf('平时成绩'): FlexColumnWidth(4),
              _selectedItems.indexOf('期末成绩'): FlexColumnWidth(4),
              _selectedItems.indexOf('课程性质'): FlexColumnWidth(4),
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
                widget.listData.length,
                (index) => TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                  children: [
                    ...List.generate(
                      _selectedItems.length,
                      (index2) => TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Text(
                            widget.listData[index]
                                    ['${_selectedItems[index2]}'] ??
                                '没有数据',
                            textAlign: _selectedItems[index2] == '课程名称'
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
}
