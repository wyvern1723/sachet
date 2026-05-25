import 'package:flutter/material.dart';

import 'gpa_table.dart';

class GradeHelpDialog extends StatelessWidget {
  const GradeHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      clipBehavior: Clip.antiAlias,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(Icons.help_outline), SizedBox(width: 8), Text('帮助')],
      ),
      children: [
        ListTile(
          title: Text('关于湘大绩点'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => _GPAInfoDialog(context),
            );
          },
        ),
      ],
    );
  }

  /// 关于湘大绩点 Dialog
  // ignore: non_constant_identifier_names
  Widget _GPAInfoDialog(context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: const Text(
                  '关于湘大绩点',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '湘潭大学采用学分绩点和平均学分绩点的方法来综合评价学生的学习质量。\n'
                '考核成绩与绩点的关系：',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const GPATable(),
              const SizedBox(height: 8),
              Text(
                '学分绩点的计算方法：\n'
                '(一) 一门学科的学分绩点=绩点×学分数\n'
                '(二) 一学期或学年平均学分绩点=所修课程学分绩点之和/所修课程学分之和\n',
                style: TextStyle(fontSize: 14),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '——湘潭大学教务处',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确认'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
