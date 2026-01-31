import 'package:html/parser.dart';

/// 从 Html 解析 成绩查询页面当前学年，可选学年，当前学期和页面显示的红色提醒文字(Danger Text)
///
/// 返回
/// (
/// String 当前学年(如 "2025"),
/// Map<学年标签: 对应的值>,
/// String 当前学期(如 "3"=>第一学期，"12"=>第二学期),
/// List<String> 提醒文字的 List（每一行为一项）
/// )
({
  String? currentSemesterYear,
  Map<String, String> semestersYears,
  String? currentSemesterIndex,
  List<String> alertTexts,
}) parseGradeSemestersAndDangerTextFromHtmlZF(String html) {
  final document = parse(html);

  // *****获取当前学年和可选学年列表*****
  final elementXnm = document.getElementById('xnm');
  if (elementXnm == null) {
    throw '找不到学年元素';
  }
  if (elementXnm.children.isEmpty) {
    throw '可选学年列表为空';
  }
  final int listLengthXnm = elementXnm.children.length;

  Map<String, String> semestersYears = {};

  // 当前学年（教务系统默认选中的学年）
  String? currentSemesterYear;
  for (int i = 0; i < listLengthXnm; i++) {
    var child = elementXnm.children[i];

    String semesterYearLabel = child.innerHtml;
    String? semesterYearValue = child.attributes['value'];

    if ((child.attributes.containsValue('selected') == true)) {
      currentSemesterYear = semesterYearValue;
    }
    if (semesterYearLabel != '' && semesterYearValue != null) {
      semestersYears.addAll({semesterYearLabel: semesterYearValue});
    }
  }

  // *****获取当前学期*****
  String? currentSemesterIndex;
  final elementXqm = document.getElementById('xqm');
  if (elementXqm != null) {
    if (elementXqm.children.isNotEmpty) {
      final int listLengthXqm = elementXqm.children.length;

      // semestersIndexes 是固定的，不需要再解析
      // Map<String, String> semestersIndexes = {};

      // 当前学期（教务系统默认选中的学期）
      for (int i = 0; i < listLengthXqm; i++) {
        var child = elementXqm.children[i];

        // String? semesterIndexLabel = child.innerHtml;
        String? semesterIndexValue = child.attributes['value'];

        if ((child.attributes.containsValue('selected') == true)) {
          currentSemesterIndex = semesterIndexValue;
        }

        // semestersIndexes 是固定的，不需要再解析
        // if (semesterIndexLabel != ''  &&  semesterIndexValue != null) {
        // semestersIndexes.addAll({semesterIndexLabel: semesterIndexValue});
        // }
      }
    }
  }

  // *****获取红色提醒文字(Danger Text)*****
  List<String> alertTexts = [];
  final elementTextDangers = document.getElementsByClassName('text-danger');
  for (final elementTextDanger in elementTextDangers) {
    final text = elementTextDanger.text.trim();
    if (text == '不合格的用红色标识，通过补考或重修及格的用蓝色标识') {
      // 跳过
      continue;
    }
    alertTexts.add(text);
  }

  return (
    currentSemesterYear: currentSemesterYear,
    semestersYears: semestersYears,
    currentSemesterIndex: currentSemesterIndex,
    alertTexts: alertTexts,
  );
}
