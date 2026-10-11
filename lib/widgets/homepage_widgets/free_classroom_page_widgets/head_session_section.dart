import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';

class HeadSessionSection extends StatefulWidget {
  const HeadSessionSection({
    super.key,
    required this.text,
    required this.section,
    required this.isSummerRountine,
  });
  final String text;
  final List<int> section;
  final bool isSummerRountine;

  @override
  State<HeadSessionSection> createState() => _HeadSessionSectionState();
}

class _HeadSessionSectionState extends State<HeadSessionSection> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            _menuController.close();
          },
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            minimumSize: WidgetStatePropertyAll(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          child: SectionSessionsTime(
            section: widget.section,
            isSummerRountine: widget.isSummerRountine,
          ),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          _menuController.isOpen
              ? _menuController.close()
              : _menuController.open();
        },
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.secondaryContainer,
          margin: const EdgeInsets.all(2.0),
          child: FittedBox(
            child: Text(widget.text, style: const TextStyle(fontSize: 10.0)),
          ),
        ),
      ),
    );
  }
}

class SectionSessionsTime extends StatelessWidget {
  const SectionSessionsTime({
    super.key,
    required this.section,
    required this.isSummerRountine,
  });
  final List<int> section;
  final bool isSummerRountine;

  @override
  Widget build(BuildContext context) {
    return isSummerRountine ? _summer(context) : _winter(context);
  }

  Widget _summer(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    String sessionsTime = '';
    List<String> time = [];
    for (final session in section) {
      final String startTime = classSessionSummerRoutineStartTime[session - 1];
      final String endTime = classSessionSummerRoutineEndTime[session - 1];
      time.add('第$session节: $startTime-$endTime');
    }
    sessionsTime = time.join('\n');

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(sessionsTime,
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _winter(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    String sessionsTimeRegular = '';
    List<String> timeRegular = [];
    for (final session in section) {
      final String startTime =
          classSessionWinterRoutineRegularStartTime[session - 1];
      final String endTime =
          classSessionWinterRoutineRegularEndTime[session - 1];
      timeRegular.add('第$session节: $startTime-$endTime');
    }
    sessionsTimeRegular = timeRegular.join('\n');

    String sessionsTimeStaggered = '';
    List<String> timeStaggered = [];
    for (final session in section) {
      final String startTime =
          classSessionWinterRoutineStaggeredStartTime[session - 1];
      final String endTime =
          classSessionWinterRoutineStaggeredEndTime[session - 1];
      timeStaggered.add('第$session节: $startTime-$endTime');
    }
    sessionsTimeStaggered = timeStaggered.join('\n');

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 2, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('其他教学区域：', style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(sessionsTimeRegular,
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('逸夫楼、信息科技大楼：', style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(sessionsTimeStaggered,
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
