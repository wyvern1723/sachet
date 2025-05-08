import 'package:flutter/material.dart';

import 'class_session.dart';

/// 最左列显示课程节次、开始时间、结束时间的 Column
class ClassSessionRoutineColumn extends StatelessWidget {
  const ClassSessionRoutineColumn({
    super.key,
    required this.weekCount,
    required this.routinedata,
  });
  final int weekCount;
  final List routinedata;

  List<Widget> _getListings() {
    List<Widget> listings = [];
    int i = 0;
    for (i = 0; i < 11; i++) {
      listings.add(ClassSession(
        session: routinedata[i]["session"],
        startTime: routinedata[i]["startTime"],
        endTime: routinedata[i]["endTime"],
      ));
    }
    return listings;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: _getListings(),
    );
  }
}
