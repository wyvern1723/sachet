import 'package:flutter/material.dart';

import 'gpa_table.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.help), SizedBox(width: 8), Text('说明')]),
      children: [
        ListTile(
          title: Text('关于湘大绩点'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => GPAInfoDialog(context));
          },
        ),
        ExpansionTile(
          title: Text('为什么卷面成绩有多个值？'),
          childrenPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          children: [
            Text(
              '在教务系统网站查询成绩只能查到平时成绩、平时成绩占比和总成绩，无法直接获取到期末成绩。\n'
              '根据公式：总成绩 = 平时成绩×平时成绩占比 + 期末成绩×期末成绩占比。\n'
              '这个公式中只有期末成绩是不确定的。\n'
              '穷举 0 - 100 的整数，代入公式中，保留使等式成立的值。\n'
              '有时存在多个值满足条件，因为计算总成绩时通过四舍五入得到整数，信息被「压缩」了，所以存在无法还原原始数值的情况。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        )
      ],
    );
  }

  /// 关于湘大绩点 Dialog
  // ignore: non_constant_identifier_names
  Widget GPAInfoDialog(context) {
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
