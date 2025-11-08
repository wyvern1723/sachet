import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/grade_zf.dart';
import 'package:sachet/providers/grade_page_zf_provider.dart';

class GradeTableZF extends StatelessWidget {
  /// 成绩查询界面（正方教务）的成绩信息表
  const GradeTableZF({super.key, required this.gradeData});
  final List<GradeZf> gradeData;

  @override
  Widget build(BuildContext context) {
    List<String> selectedItems =
        context.select<GradePageZFProvider, List<String>>(
            (provider) => provider.selectedItems);
    return selectedItems.isNotEmpty
        ? Table(
            columnWidths: <int, TableColumnWidth>{
              selectedItems.indexOf('课程名称'): FlexColumnWidth(7),
              selectedItems.indexOf('学期'): FlexColumnWidth(5),
              selectedItems.indexOf('任课教师'): FlexColumnWidth(4),
              selectedItems.indexOf('课程性质'): FlexColumnWidth(6),
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
                  selectedItems.length,
                  (index) => TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        selectedItems[index],
                        textAlign: selectedItems[index] == '课程名称'
                            ? TextAlign.start
                            : TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              ...List.generate(
                gradeData.length,
                (index) => TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                  children: [
                    ...selectedItems.map(
                      (e) => TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Text(
                            gradeData[index].item(e),
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
          )
        : SizedBox();
  }
}
