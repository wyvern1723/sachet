import 'package:html/parser.dart';

/// 成绩单打印页面，从 html 解析可选的成绩单格式
///
/// Return:
///
/// e.g.,
///
/// {
/// "中文主修成绩单（最高考虑加分）": "10530-zw-zgmrgs",
/// "中文主修成绩单（全程）": "10530-zw-qcmrgs",
/// "中文主修成绩单（最高不考虑加分）": "10530-zw-zgbjf"
/// }
Map<String, String> parseScorePdfTypesFromHtmlZF(String html) {
  final document = parse(html);

  final elementGsdygx = document.getElementById('gsdygx');
  if (elementGsdygx == null) {
    throw '找不到成绩单格式元素';
  }
  if (elementGsdygx.children.isEmpty) {
    throw '可选成绩单格式列表为空';
  }

  Map<String, String> scorePdfTypes = {};

  for (int i = 0; i < elementGsdygx.children.length; i++) {
    final child = elementGsdygx.children[i];
    final String label = child.innerHtml;
    final String? value = child.attributes['value'];
    if (label != '' && value != null) {
      scorePdfTypes.addAll({label: value});
    }
  }

  return scorePdfTypes;
}
