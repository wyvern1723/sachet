import 'package:flutter/material.dart';
import 'package:sachet/provider/course_card_settings_provider.dart';
import 'package:provider/provider.dart';

class ClassSession extends StatelessWidget {
  /// 最左列显示课程节次、开始时间、结束时间的 Column 里的一个 Container
  const ClassSession({
    super.key,
    required this.session,
    required this.startTime,
    required this.endTime,
  });
  final String session; // 课程节次，1、2、3、4、5、6、7、8、9、10、11
  final String startTime; // 开始时间 08:00
  final String endTime; // 结束时间 08:45

  @override
  Widget build(BuildContext context) {
    double cardHeight = context.select<CourseCardSettingsProvider, double>(
        (courseCardSettingsProvider) => courseCardSettingsProvider.cardHeight);
    return Container(
      height: cardHeight,
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    session,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  FittedBox(
                    child: Text(startTime),
                  ),
                  FittedBox(
                    child: Text(endTime),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
