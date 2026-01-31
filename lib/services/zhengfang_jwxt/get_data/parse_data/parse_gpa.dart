import 'package:sachet/models/gpa_response_zf.dart';

/// 解析绩点排名数据
///
/// 返回： GpaResponseZF
GpaResponseZF parseGPAZF(Map jsonData) {
  List items = jsonData['items'];
  if (items.isEmpty) {
    throw '没有符合条件记录!';
  }
  final item = items[0];
  GpaResponseZF gpaResponse = GpaResponseZF.fromJson(item);

  return gpaResponse;
}
