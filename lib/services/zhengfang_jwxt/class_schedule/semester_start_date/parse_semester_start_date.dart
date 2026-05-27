import 'package:html/parser.dart';

(String, DateTime) parseSemesterStartDateFromHtml(String html) {
  final document = parse(html);

  final thElements = document.getElementsByTagName('th');

  // 检查是否至少有两个 <th> 标签
  if (thElements.length < 2) {
    throw '没有找到期望的 <th> 元素';
  }

  // 获取第二个 <th> 标签的文本内容
  String targetMsg = thElements[1].text.trim();

  // targetMsg 内容为: 2025-2026学年1学期(2025-09-01至2026-01-18)

  /*
  // 1. 分割字符串，提取括号内的日期范围部分
  if (targetMsg.split('学期(').length < 2) {
    throw '解析学期开始日期失败: $targetMsg';
  }
  String dateRangePart = targetMsg.split('学期(')[1].trim();
  // 2. 去掉末尾的右括号
  String dateRange = dateRangePart.replaceAll(')', '');
  // 3. 用“至”分割，取第一部分作为开始日期
  String startDateStr = dateRange.split('至')[0].trim();
  */

  final regex = RegExp(r'学期\((\d{4}-\d{2}-\d{2})至');
  final match = regex.firstMatch(targetMsg);

  if (match == null) {
    throw '解析学期开始日期失败: $targetMsg';
  }
  final startDateStr = match.group(1)!;
  DateTime? startDate = DateTime.tryParse(startDateStr);
  if (startDate == null) {
    throw '解析学期开始日期失败: $targetMsg';
  }

  return (startDateStr, startDate);
}
