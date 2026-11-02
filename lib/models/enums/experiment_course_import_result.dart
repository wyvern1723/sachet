/// 同时导入实验课表的结果
enum ExperimentCourseImportResult {
  /// 用户没有选择导入实验课表
  notRequested,

  /// 成功导入实验课表
  imported,

  /// 教务系统中没有查询到实验课表
  empty,

  /// 获取或解析实验课表时遇到问题（不影响理论课表的导入）
  failed,
}
