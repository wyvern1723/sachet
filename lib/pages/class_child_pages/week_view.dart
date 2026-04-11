import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/pages/class_child_pages/single_week_page.dart';
import 'package:sachet/providers/class_page_provider.dart';

class WeekView extends StatefulWidget {
  final List<List<CourseSchedule>>? courseScheduleItemsList;
  final Map? courseColorData;
  final List? classSessionSummerDataList;
  final List? classSessionWinterDataList;

  const WeekView({
    super.key,
    this.courseScheduleItemsList,
    this.courseColorData,
    this.classSessionSummerDataList,
    this.classSessionWinterDataList,
  });

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ClassPageProvider>()
          .pageController
          .jumpToPage(context.read<ClassPageProvider>().currentWeekCount - 1);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: context.read<ClassPageProvider>().pageController,
        onPageChanged: (value) {
          context.read<ClassPageProvider>().updateCurrentWeekCount(value + 1);
        },
        allowImplicitScrolling: true,
        children: [
          for (int i = 1; i < 21; i++)
            SingleWeekPage(
              weekCount: i,
              courseScheduleItemsList: widget.courseScheduleItemsList,
              courseColorData: widget.courseColorData,
              classSessionSummerDataList: widget.classSessionSummerDataList,
              classSessionWinterDataList: widget.classSessionWinterDataList,
            ),
        ]);
  }
}
