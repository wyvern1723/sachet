class FreeClassroomFilterOptionsZF {
  /// 可选的学期选项 Map<label: value>
  ///
  /// e.g.
  ///
  /// ```
  /// {
  ///   "2025-2026-3": "2025-16",
  ///   "2025-2026-2": "2025-12",
  ///   "2025-2026-1": "2025-3",
  ///   "2024-2025-3": "2024-16",
  ///   "2024-2025-2": "2024-12"
  /// },
  /// ```
  final Map<String, String> semesterOptions;

  /// 默认选择的学期的 value, e.g., "2025-16","2025-12","2025-3","2024-16"
  final String? selectedSemester;

  /// 可选的楼号选项 Map<label: value>
  ///
  /// e.g.
  ///
  /// ```
  /// {
  ///   "全部": "",
  ///   "北山画室": "209",
  ///   "北山阶梯": "206",
  ///   "材料大楼": "907"
  /// },
  /// ```
  final Map<String, String> teachingBuildingOptions;

  /// 默认选择的楼号的 value
  final String? selectedTeachingBuilding;

  /// 可选的场地类型选项 Map<label: value>
  ///
  /// e.g.
  ///
  /// ```
  /// {
  ///   "全部": "",
  ///   "画室": "242AD80DD82F326AE06364FD18AC1791",
  ///   "工作室": "242AD80DD830326AE06364FD18AC1791",
  ///   "教室": "01",
  ///   "机房": "242A39144A5D320DE06364FD18AC0E46"
  ///  },
  /// ```
  final Map<String, String> placeTypeOptions;

  /// 默认选择的场地类型的 value
  final String? selectedPlaceType;

  FreeClassroomFilterOptionsZF({
    required this.semesterOptions,
    this.selectedSemester,
    required this.teachingBuildingOptions,
    this.selectedTeachingBuilding,
    required this.placeTypeOptions,
    this.selectedPlaceType,
  });
}
