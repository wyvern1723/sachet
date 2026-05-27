/// 解析成绩单链接
///
/// e.g.,
/// - rawInput: "/jwglxt/templete/scorePrint/score_202312345678_1769943281937.pdf#成功"
///
/// - return: "https://jw.xtu.edu.cn/jwglxt/templete/scorePrint/score_202312345678_1769943281937.pdf"
String parseScorePdfLinkZF(String rawInput) {
  final path = rawInput.split('#').first.trim();
  if (!path.startsWith('/')) {
    throw Exception('解析链接失败, 路径格式异常: $rawInput');
  }
  final pdfUrl = 'https://jw.xtu.edu.cn$path';
  return pdfUrl;
}
