import 'package:html/parser.dart';

({
  Map<String, String> startSemesters,
  Map<String, String> endSemesters,
}) parseGPASemestersFromHtmlZF(String html) {
  final document = parse(html);

  // *****获取可选起始学年学期*****
  final elementQsXnxq = document.getElementById('qsXnxq');
  if (elementQsXnxq == null) {
    throw '找不到起始学年学期元素';
  }
  if (elementQsXnxq.children.isEmpty) {
    throw '可选起始学年学期列表为空';
  }

  Map<String, String> startSemesters = {};

  for (int i = 0; i < elementQsXnxq.children.length; i++) {
    final child = elementQsXnxq.children[i];
    final String label = child.innerHtml;
    final String? value = child.attributes['value'];
    if (label != '' && value != null) {
      startSemesters.addAll({label: value});
    }
  }

  // *****获取可选终止学年学期*****
  final elementZzXnxq = document.getElementById('zzXnxq');
  if (elementZzXnxq == null) {
    throw '找不到终止学年学期元素';
  }
  if (elementZzXnxq.children.isEmpty) {
    throw '可选终止学年学期列表为空';
  }

  Map<String, String> endSemesters = {};

  for (int i = 0; i < elementZzXnxq.children.length; i++) {
    final child = elementQsXnxq.children[i];
    final String label = child.innerHtml;
    final String? value = child.attributes['value'];
    if (label != '' && value != null) {
      endSemesters.addAll({label: value});
    }
  }

  return (startSemesters: startSemesters, endSemesters: endSemesters);
}
