import 'package:flutter/material.dart';
import 'package:sachet/provider/app_global.dart';

class CourseCardSettingsProvider extends ChangeNotifier {
  CourseCardSettings get _courseCardSettings => AppGlobal.courseCardSettings;

  double get cardHeight => _courseCardSettings.cardHeight ?? 65;
  double get cardBorderRadius => _courseCardSettings.cardBorderRadius ?? 6.0;
  double get cardMargin => _courseCardSettings.cardMargin ?? 2.0;
  double get titleFontSize => _courseCardSettings.titleFontSize ?? 13.0;
  double get placeFontSize => _courseCardSettings.placeFontSize ?? 12.0;
  double get instructorFontSize =>
      _courseCardSettings.instructorFontSize ?? 12.0;
  int get titleFontWeight => _courseCardSettings.titleFontWeight ?? 7;
  int get placeFontWeight => _courseCardSettings.placeFontWeight ?? 4;
  int get instructorFontWeight => _courseCardSettings.instructorFontWeight ?? 4;
  int get titleMaxLines => _courseCardSettings.titleMaxLines ?? 3;
  int get placeMaxLines => _courseCardSettings.placeMaxLines ?? 2;
  int get instructorMaxLines => _courseCardSettings.instructorMaxLines ?? 2;
  String get titleTextColor =>
      _courseCardSettings.titleTextColor ?? "#F2FFFFFF";
  String get placeTextColor =>
      _courseCardSettings.placeTextColor ?? "#F2FFFFFF";
  String get instructorTextColor =>
      _courseCardSettings.instructorTextColor ?? "#F2FFFFFF";

  void setCardHeight(double value) {
    if (value != _courseCardSettings.cardHeight) {
      _courseCardSettings.cardHeight = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setCardBorderRadius(double value) {
    if (value != _courseCardSettings.cardBorderRadius) {
      _courseCardSettings.cardBorderRadius = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setCardMargin(double value) {
    if (value != _courseCardSettings.cardMargin) {
      _courseCardSettings.cardMargin = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setTitleFontSize(double value) {
    if (value != _courseCardSettings.titleFontSize) {
      _courseCardSettings.titleFontSize = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setPlaceFontSize(double value) {
    if (value != _courseCardSettings.placeFontSize) {
      _courseCardSettings.placeFontSize = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setInstructorFontSize(double value) {
    if (value != _courseCardSettings.instructorFontSize) {
      _courseCardSettings.instructorFontSize = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setTitleFontWeight(int value) {
    if (value != _courseCardSettings.titleFontWeight) {
      _courseCardSettings.titleFontWeight = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setPlaceFontWeight(int value) {
    if (value != _courseCardSettings.placeFontWeight) {
      _courseCardSettings.placeFontWeight = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setInstructorFontWeight(int value) {
    if (value != _courseCardSettings.instructorFontWeight) {
      _courseCardSettings.instructorFontWeight = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setTitleMaxLines(int value) {
    if (value != _courseCardSettings.titleMaxLines) {
      _courseCardSettings.titleMaxLines = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setPlaceMaxLines(int value) {
    if (value != _courseCardSettings.placeMaxLines) {
      _courseCardSettings.placeMaxLines = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setInstructorMaxLines(int value) {
    if (value != _courseCardSettings.instructorMaxLines) {
      _courseCardSettings.instructorMaxLines = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setTitleTextColor(String value) {
    if (value != _courseCardSettings.titleTextColor) {
      _courseCardSettings.titleTextColor = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setPlaceTextColor(String value) {
    if (value != _courseCardSettings.placeTextColor) {
      _courseCardSettings.placeTextColor = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }

  void setInstructorTextColor(String value) {
    if (value != _courseCardSettings.instructorTextColor) {
      _courseCardSettings.instructorTextColor = value;
      AppGlobal.saveCourseCardSettings();
      notifyListeners();
    }
  }
}

FontWeight intToFontWeight(int index) {
  return const <int, FontWeight>{
    0: FontWeight.w100,
    1: FontWeight.w200,
    2: FontWeight.w300,
    3: FontWeight.w400,
    4: FontWeight.w500,
    5: FontWeight.w600,
    6: FontWeight.w700,
    7: FontWeight.w800,
    8: FontWeight.w900,
  }[index]!;
}
