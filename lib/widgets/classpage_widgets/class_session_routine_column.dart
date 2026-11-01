import 'package:flutter/material.dart';

import 'package:sachet/models/session_routine.dart';

import 'class_session.dart';

/// 最左列显示课程节次、开始时间、结束时间的 Column
class ClassSessionRoutineColumn extends StatelessWidget {
  const ClassSessionRoutineColumn({
    super.key,
    required this.routineData,
    required this.cardHeight,
  });
  final List<SessionPeriod> routineData;
  final double cardHeight;

  List<Widget> _getListings() {
    List<Widget> sessions = [];
    int i = 0;
    for (i = 0; i < 11; i++) {
      final period = routineData[i];
      sessions.add(ClassSession(
        session: '${period.session}',
        startTime: period.startTime,
        endTime: period.endTime,
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
