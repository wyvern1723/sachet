import 'package:flutter/material.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';
import 'package:sachet/widgets/settingspage_widgets/customize_settings_widgets/set_course_card_appearance.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class CourseCardItem extends StatelessWidget {
  const CourseCardItem({
    super.key,
    required this.coursecardcategory,
    required this.text,
  });
  final CourseItemCategory coursecardcategory;
  final String text;

  @override
  Widget build(BuildContext context) {
    var courseCardSettings = context.watch<CourseCardSettingsProvider>();
    if (coursecardcategory == CourseItemCategory.title
        ? courseCardSettings.titleMaxLines != 0
        : coursecardcategory == CourseItemCategory.place
            ? courseCardSettings.placeMaxLines != 0
            : courseCardSettings.instructorMaxLines != 0) {
      return Text(
        text,
        style: TextStyle(
          fontWeight:
              intToFontWeight(coursecardcategory == CourseItemCategory.title
                  ? courseCardSettings.titleFontWeight
                  : coursecardcategory == CourseItemCategory.place
                      ? courseCardSettings.placeFontWeight
                      : courseCardSettings.instructorFontWeight),
          fontSize: coursecardcategory == CourseItemCategory.title
              ? courseCardSettings.titleFontSize
              : coursecardcategory == CourseItemCategory.place
                  ? courseCardSettings.placeFontSize
                  : courseCardSettings.instructorFontSize,
          color: colorFromHex(coursecardcategory == CourseItemCategory.title
              ? courseCardSettings.titleTextColor
              : coursecardcategory == CourseItemCategory.place
                  ? courseCardSettings.placeTextColor
                  : courseCardSettings.instructorTextColor),
        ),
        textAlign: TextAlign.center,
        maxLines: coursecardcategory == CourseItemCategory.title
            ? courseCardSettings.titleMaxLines
            : coursecardcategory == CourseItemCategory.place
                ? courseCardSettings.placeMaxLines
                : courseCardSettings.instructorMaxLines,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return SizedBox();
    }
  }
}
