import 'package:flutter/material.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/get_exam_scores.dart';
import 'package:sachet/widgets/utils_widgets/login_expired.dart';
import 'package:provider/provider.dart';

import '../../../providers/grade_page_provider.dart';

class GPAWidget extends StatelessWidget {
  /// GPAWidget Card
  const GPAWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String semester = context
        .select<GradePageProvider, String>((gradeModel) => gradeModel.semester);
    return FutureBuilder(
        future: getGPAandRankData(semester),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              if (snapshot.error == '登录失效，请重新登录') {
                return LoginExpired();
              } else {
                return Text('${snapshot.error}');
              }
            } else {
              return GPACardInFutureBuilder(
                data: snapshot.data ??
                    {
                      "平均绩点": "--",
                      "平均成绩": "--",
                      "绩点班级排名": "--",
                      "绩点专业排名": "--"
                    },
              );
            }
          } else {
            return SizedBox(
              height: 148,
              child: Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
        });
  }
}

class GPACardInFutureBuilder extends StatelessWidget {
  final Map data;

  const GPACardInFutureBuilder({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPA: ${data.values.elementAt(0)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    SizedBox(height: 4),

                    //平均分数
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '平均分数: ${data.values.elementAt(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    //班级排名
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '班级排名: ${data.values.elementAt(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),

                    //年级排名
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.groups,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '专业排名: ${data.values.elementAt(3)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
