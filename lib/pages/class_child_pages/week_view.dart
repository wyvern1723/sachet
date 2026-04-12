import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/course_schedule.dart';
import 'package:sachet/pages/class_child_pages/single_week_page.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';

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
  double _cardHeight = 65.0;
  double _baseCardHeight = 65.0;
  int _pointerCount = 0;

  @override
  void initState() {
    _cardHeight = context.read<CourseCardSettingsProvider>().cardHeight;
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
    final double persistedCardHeight =
        context.select<CourseCardSettingsProvider, double>(
            (provider) => provider.cardHeight);

    // 如果外部 Provider 变了，且当前没有手势操作，则同步本地状态
    // 使用 > 0.1 避免浮点数精度问题导致的无限重建
    if (_pointerCount == 0 && (persistedCardHeight - _cardHeight).abs() > 0.1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _cardHeight = persistedCardHeight);
        }
      });
    }

    return Listener(
      onPointerDown: (event) => setState(() => _pointerCount++),
      onPointerUp: (event) => setState(() => _pointerCount--),
      onPointerCancel: (event) => setState(() => _pointerCount--),
      child: GestureDetector(
        onScaleStart: (details) {
          _baseCardHeight = _cardHeight;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount < 2) return;
          setState(() {
            _cardHeight = (_baseCardHeight * details.scale).clamp(36.0, 100.0);
          });
        },
        onScaleEnd: (details) {
          context.read<CourseCardSettingsProvider>().setCardHeight(_cardHeight);
        },
        child: PageView(
            controller: context.read<ClassPageProvider>().pageController,
            onPageChanged: (value) {
              context
                  .read<ClassPageProvider>()
                  .updateCurrentWeekCount(value + 1);
            },
            physics: _pointerCount >= 2
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            allowImplicitScrolling: true,
            children: [
              for (int i = 1; i < 21; i++)
                SingleWeekPage(
                  weekCount: i,
                  courseScheduleItemsList: widget.courseScheduleItemsList,
                  courseColorData: widget.courseColorData,
                  classSessionSummerDataList: widget.classSessionSummerDataList,
                  classSessionWinterDataList: widget.classSessionWinterDataList,
                  cardHeight: _cardHeight,
                  pointerCount: _pointerCount,
                ),
            ]),
      ),
    );
  }
}
