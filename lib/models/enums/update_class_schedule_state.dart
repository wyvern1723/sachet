/// 更新课表的状态
enum UpdateClassScheduleState {
  /// 正在获取学期（当前学期和其他可选学期）  成功 --> selectSemester; 失败 --> loginExpired/gettingSemestersFaild
  gettingSemester,

  /// 用户选择学期（默认是从网页获取的当前学期)   成功 --> updating; 失败 --> failed
  selectSemester,

  /// 开始更新
  updating,

  /// 设置学期开始日期（应用内没有所选学期的开始日期，需要用户手动设置）
  setSemesterStartDate,

  /// 更新完成（应用内已有所选学期的开始日期，无需用户设置）
  updatedClassSchedule,

  /// 登录过期（登录失效）
  loginExpired,

  /// 因为其它问题导致更新课表失败
  updateClassScheduleFailed,

  /// 因为其它问题导致获取学期失败
  getSemestersFailed,
}
