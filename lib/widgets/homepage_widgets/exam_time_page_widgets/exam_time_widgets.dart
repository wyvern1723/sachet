import 'package:flutter/material.dart';
import 'package:sachet/utils/transform.dart';

class ExamTimeCard extends StatelessWidget {
  const ExamTimeCard({
    super.key,
    required this.course,
    required this.time,
    required this.place,
    required this.note,
    required this.isHalf,
  });

  final String course;
  final String time;
  final String place;
  final String note;

  // 是否是 DoubleColumn 的组件(只占屏幕宽度 1/2)
  final bool isHalf;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 课程名
              Text(
                course,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),

              // 时间
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      time == ''
                          ? '空'
                          : isHalf
                              ? time
                              : '$time  ${weekdayToXingQiJi[DateTime.parse(time.split(' ')[0]).weekday]}',
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),

              // 如果有时间且是 DoubleColumn 用的，显示星期几
              if (isHalf && time != '')
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        weekdayToXingQiJi[
                                DateTime.parse(time.split(' ')[0]).weekday] ??
                            '',
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

              // 地点
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place == '' ? '空' : place,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              // 如果有备注，显示备注
              // TODO: 如果有其他项，也要显示
              if (note != '')
                Text(
                  '备注：$note',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
            ]
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: e,
                    ))
                .toList(), // 在 children 间添加间隔(gap)
          ),
        ),
      ),
    );
  }
}
