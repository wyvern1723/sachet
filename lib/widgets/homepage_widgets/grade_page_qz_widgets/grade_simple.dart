import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/grade_page_qz_provider.dart';
import '../../utils_widgets/login_expired_qz.dart';

class GradeSimpleQZ extends StatefulWidget {
  /// 成绩信息简单表（强智教务）
  const GradeSimpleQZ({super.key});

  @override
  State<GradeSimpleQZ> createState() => _GradeSimpleQZState();
}

class _GradeSimpleQZState extends State<GradeSimpleQZ> {
  @override
  Widget build(BuildContext context) {
    context.select<GradePageQZProvider, String>(
        (gradePageProvider) => (gradePageProvider.semester)); // 监听 semester 变化
    return FutureBuilder(
      future: context.read<GradePageQZProvider>().getExamScoresSimpleData(),
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
            return Column(
              children: [
                SizedBox(height: 20),
                GradeSimpleTableQZ(data: snapshot.data ?? []),
              ],
            );
          }
        } else {
          return Column(
            children: [
              SizedBox(height: 20),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
      },
    );
  }
}

class GradeSimpleTableQZ extends StatelessWidget {
  final List data;

  /// 成绩简单页面的信息表（强智教务）
  const GradeSimpleTableQZ({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
        columnWidths: const <int, TableColumnWidth>{
          // 第一列：课程名称
          0: FlexColumnWidth(7),
          // 第二列：学分
          1: FlexColumnWidth(2),
          // 第三列：最终成绩
          2: FlexColumnWidth(3)
        },
        border: TableBorder.all(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        children: [
          TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              children: const [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('课程名称'),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('学分'),
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('最终成绩'),
                    ),
                  ),
                ),
              ]),
          ...List.generate(
            data.length,
            (index) => TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(data[index]['课程名称']),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(data[index]['学分']),
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(data[index]['总成绩']),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]);
  }
}
