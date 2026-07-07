enum AppFolder {
  /// 储存课程表数据的文件夹名称
  classSchedule('class_schedule'),

  /// 储存课程名称与对应颜色数据的文件夹名称
  courseColor('course_color'),

  /// 旧教务系统（强智教务系统）的缓存数据文件夹名称
  cachedData('cached_data'),

  /// 新教务系统（正方教务系统）的缓存数据文件夹名称
  cachedDataZF('cached_data_zf');

  const AppFolder(this.name);
  final String name;
}

enum CachedDataZFSubFolder {
  /// 考试时间缓存数据文件夹名称
  examTimeCache('exam_time');

  /// 新教务系统（正方教务系统）的缓存数据文件夹的所有子文件夹名称
  const CachedDataZFSubFolder(this.name);
  final String name;
}
