import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/services/zhengfang_jwxt/grade/models/grade_response_zf.dart';
import 'package:sachet/providers/grade_page_zf_provider.dart';

class GradeTableZF extends StatelessWidget {
  /// 成绩查询界面（正方教务）的成绩信息表
  const GradeTableZF({super.key, required this.gradeData});
  final List<GradeResponseZF> gradeData;

  @override
  Widget build(BuildContext context) {
    List<String> selectedItems =
        context.select<GradePageZFProvider, List<String>>(
            (provider) => provider.selectedItems);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (selectedItems.isEmpty) {
      return SizedBox();
    }

    return SelectionArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Table(
          columnWidths: <int, TableColumnWidth>{
            selectedItems.indexOf('课程名称'): FlexColumnWidth(7),
            selectedItems.indexOf('学期'): FlexColumnWidth(5),
            selectedItems.indexOf('任课教师'): FlexColumnWidth(4),
            selectedItems.indexOf('课程性质'): FlexColumnWidth(6),
          },
          defaultColumnWidth: FlexColumnWidth(2),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(color: colorScheme.surfaceContainer),
              children: List.generate(
                selectedItems.length,
                (index) => TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      selectedItems[index] == '课程名称' ? 8.0 : 4.0,
                      6.0,
                      4.0,
                      6.0,
                    ),
                    child: Text(
                      selectedItems[index],
                      style: textTheme.labelMedium,
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
                decoration: BoxDecoration(color: colorScheme.surface),
                children: [
                  ...selectedItems.map(
                    (e) => TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          e == '课程名称' ? 8.0 : 4.0,
                          4.0,
                          4.0,
                          4.0,
                        ),
                        child: Text(
                          gradeData[index].item(e),
                          style: textTheme.bodySmall,
                          textAlign:
                              e == '课程名称' ? TextAlign.start : TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
