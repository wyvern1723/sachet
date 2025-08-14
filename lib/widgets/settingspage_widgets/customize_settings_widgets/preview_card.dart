import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/widgets/classpage_widgets/course_card.dart';

// 预览卡片 Widget
class PreviewCard extends StatefulWidget {
  const PreviewCard({
    super.key,
  });

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  @override
  Widget build(BuildContext context) {
    CourseSchedule courseSchedule =
        CourseSchedule(title: "龙吼之道", instructor: "艾恩盖尔", place: "高吼峰修道院");
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 5 / 39,
        child: CourseCardWidget(
          courseColorData: {"龙吼之道": colorToHex(Colors.cyan)},
          courseSchedule: courseSchedule,
          onTap: null,
        ),
      ),
    );
  }
}
