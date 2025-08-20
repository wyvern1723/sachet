import 'package:sachet/services/qiangzhi_jwxt/get_data/fetch_data_http/fetch_class_schedule_semesters.dart';
import 'package:html/parser.dart';

/// 获取课表的可选择学期
///
/// return [当前学期,{semesterLabel: semesterValue,.......} ({学期名称(网页显示的文本): 学期值(实际的值)})]
///
/// {semesterLabel: semesterValue,.......}: eg. {"2024-2025-2":"2024-2025-2","2024-2025-1":"2024-2025-1","2023-2024-2":"2023-2024-2"}
Future<List> getClassScheduleSemestersDataQZ() async {
  var result = await fetchClassScheduleSemestersDataQZ();

  var document = parse(encoding: '', result);

  // pathElement 表示在 html DOM 里的位置，减少代码量。
  var pathElement = document.getElementById('xnxq01id');
  var listLength = pathElement?.children.length ?? 10;

  Map<String, String> data = {};

  String? currentSemester = '';
  for (int i = 1; i < listLength + 1; i++) {
    var child = pathElement?.children[i - 1];

    String? semesterLabel = child?.innerHtml;
    String? semesterValue = child?.attributes['value'];

    if ((child?.attributes.containsValue('selected') == true)) {
      currentSemester = semesterValue;
    }
    data.addAll({
      semesterLabel ?? '': semesterValue ?? '',
    });
  }

  return [currentSemester, data];
}
