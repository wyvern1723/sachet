import 'package:sachet/constants/url_constants.dart';

enum JwxtType {
  qiangzhi('强智教务系统', '旧教务系统', jwxtBaseUrlHttps),
  zhengfang('正方教务系统', '新教务系统', newJwxtBaseUrl);

  const JwxtType(this.label, this.description, this.baseUrl);
  final String label;
  final String description;
  final String baseUrl;
}
