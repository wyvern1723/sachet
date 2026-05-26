class CourseCardSettings {
  double? cardHeight;
  double? cardBorderRadius;
  double? cardMargin;
  double? titleFontSize;
  double? placeFontSize;
  double? instructorFontSize;
  int? titleFontWeight;
  int? placeFontWeight;
  int? instructorFontWeight;
  int? titleMaxLines;
  int? placeMaxLines;
  int? instructorMaxLines;
  String? titleTextColor;
  String? placeTextColor;
  String? instructorTextColor;

  CourseCardSettings({
    this.cardHeight,
    this.cardBorderRadius,
    this.cardMargin,
    this.titleFontSize,
    this.placeFontSize,
    this.instructorFontSize,
    this.titleFontWeight,
    this.placeFontWeight,
    this.instructorFontWeight,
    this.titleMaxLines,
    this.placeMaxLines,
    this.instructorMaxLines,
    this.titleTextColor,
    this.placeTextColor,
    this.instructorTextColor,
  });

  CourseCardSettings.fromJson(Map<String, dynamic> json) {
    cardHeight = json['cardHeight'];
    cardBorderRadius = json['cardBorderRadius'];
    cardMargin = json['cardMargin'];
    titleFontSize = json['TitleFontSize'];
    placeFontSize = json['PlaceFontSize'];
    instructorFontSize = json['InstructorFontSize'];
    titleFontWeight = json['TitleFontWeight'];
    placeFontWeight = json['PlaceFontWeight'];
    instructorFontWeight = json['InstructorFontWeight'];
    titleMaxLines = json['TitleMaxLines'];
    placeMaxLines = json['PlaceMaxLines'];
    instructorMaxLines = json['InstructorMaxLines'];
    titleTextColor = json['TitleTextColor'];
    placeTextColor = json['PlaceTextColor'];
    instructorTextColor = json['InstructorTextColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cardHeight'] = cardHeight;
    data['cardBorderRadius'] = cardBorderRadius;
    data['cardMargin'] = cardMargin;
    data['TitleFontSize'] = titleFontSize;
    data['PlaceFontSize'] = placeFontSize;
    data['InstructorFontSize'] = instructorFontSize;
    data['TitleFontWeight'] = titleFontWeight;
    data['PlaceFontWeight'] = placeFontWeight;
    data['InstructorFontWeight'] = instructorFontWeight;
    data['TitleMaxLines'] = titleMaxLines;
    data['PlaceMaxLines'] = placeMaxLines;
    data['InstructorMaxLines'] = instructorMaxLines;
    data['TitleTextColor'] = titleTextColor;
    data['PlaceTextColor'] = placeTextColor;
    data['InstructorTextColor'] = instructorTextColor;
    return data;
  }
}
