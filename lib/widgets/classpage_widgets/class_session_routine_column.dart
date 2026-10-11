import 'package:flutter/material.dart';

import 'class_session.dart';

/// 最左列显示课程节次、开始时间、结束时间的 Column
class ClassSessionRoutineColumn extends StatelessWidget {
  const ClassSessionRoutineColumn({
    super.key,
    required this.weekCount,
    required this.routinedata,
    required this.cardHeight,
  });
  final int weekCount;
  final List? routinedata;
  final double cardHeight;

  List<Widget> _getListings() {
    List<Widget> sessions = [];
    int i = 0;
    for (i = 0; i < 11; i++) {
      sessions.add(ClassSession(
        session: routinedata?[i]["session"],
        startTime: routinedata?[i]["startTime"],
        endTime: routinedata?[i]["endTime"],
        cardHeight: cardHeight,
      ));
      if ([1, 3, 5, 7].contains(i)) {
        sessions.add(_break());
      }
    }
    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: _getListings(),
    );
  }

  /// 休息时间段（占位空白）
  Widget _break() {
    double height = 0.05 * cardHeight;
    return SizedBox(height: height);
  }
}
