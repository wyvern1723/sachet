import 'package:flutter/material.dart';
import 'package:sachet/utils/transform.dart';

class CourseDetailsBottomSheet extends StatelessWidget {
  const CourseDetailsBottomSheet({
    super.key,
    required this.courseTitle,
    required this.weekday,
    required this.weeks,
    required this.lengths,
    required this.instructors,
    required this.places,
    required this.sectionsShowText,
  });
  final String courseTitle;
  final int weekday;
  final List weeks;
  final List lengths;
  final List instructors;
  final List places;
  final List sectionsShowText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final safeAreaInsets = MediaQuery.of(context).padding;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, safeAreaInsets.bottom + 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SelectionArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8.0),
                        child: Text(
                          courseTitle,
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                        leading: Icon(
                          Icons.school_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                          applyTextScaling: true,
                        ),
                        title: Text(instructors.join(' / '),
                            style: textTheme.bodyLarge),
                        visualDensity: VisualDensity.compact,
                      ),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                        leading: Icon(
                          Icons.place_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                          applyTextScaling: true,
                        ),
                        title: Text(places.join(' / '),
                            style: textTheme.bodyLarge),
                        visualDensity: VisualDensity.compact,
                      ),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                        leading: Icon(
                          Icons.schedule_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                          applyTextScaling: true,
                        ),
                        title: Text(
                          '${weekdayToXingQiJi[weekday]} ${sectionsShowText.join(' / ')}',
                          style: textTheme.bodyLarge,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(
                    height: 1,
                    indent: 24,
                    endIndent: 24,
                    color: colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 18,
                        applyTextScaling: true,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '上课周次',
                        style: textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 8,
                    children: List.generate(20, (index) {
                      int weekCount = index + 1;
                      bool isActive = weeks.contains(weekCount);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          color: isActive
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            child: SizedBox.square(
                              dimension: 38,
                              child: Center(
                                child: Text(
                                  '$weekCount',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isActive
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
