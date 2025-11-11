import 'package:flutter/material.dart';
import 'package:sachet/models/exam_time_zf.dart';

class ExamTimeCardZF extends StatelessWidget {
  /// 考试时间查询页面（正方教务）的每门课程的考试时间信息 Card
  const ExamTimeCardZF({
    super.key,
    required this.examTime,
    required this.isDetailedView,
  });

  final ExamTimeZF examTime;
  final bool isDetailedView;

  @override
  Widget build(BuildContext context) {
    return isDetailedView
        ? _buildDetailedCard(context)
        : _buildSimpleCard(context);
  }

  Widget _buildDetailedCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Stack(
        children: [
          // 在卡片右上角显示学期
          Positioned(
            top: 8,
            right: 16,
            child: Text(
              '${examTime.semesterYear}-${examTime.semesterIndex}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 课程名称
                  Text(
                    examTime.courseTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // 时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          examTime.time,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  // 地点
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          examTime.place,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.0),
                  Text(
                    '考试名称: ${examTime.examName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                  Text(
                    '场地简称: ${examTime.placeShort}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                  // Text(
                  //   '教师信息: ${examTime.instructorInfo}',
                  //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //       color: Theme.of(context).colorScheme.onSecondaryContainer),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Stack(
        children: [
          // 在卡片右上角显示学期
          Positioned(
            top: 8,
            right: 16,
            child: Text(
              '${examTime.semesterYear}-${examTime.semesterIndex}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 课程名称
                  Text(
                    examTime.courseTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: [
                      // 考试时间
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            examTime.time,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 16,
                              // height: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),

                      // 考试地点
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            examTime.place,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
