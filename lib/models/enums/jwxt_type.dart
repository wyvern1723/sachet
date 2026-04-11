import 'package:sachet/constants/url_constants.dart';

enum JwxtType {
  qiangzhi('强智教务系统', '旧教务系统', jwxtBaseUrlHttps, '2024-2025-2 前'),
  zhengfang('正方教务系统', '新教务系统', newJwxtBaseUrl, '2025-2026-1 后');

  const JwxtType(
    this.label,
    this.description,
    this.baseUrl,
    this.classScheduleDescription,
  );
  final String label;
  final String description;
  final String baseUrl;
  final String classScheduleDescription;
}
