import 'package:html/parser.dart';

/// 从正方教务系统培养方案查询页面的 HTML 中，解析年级、学院、专业的下拉选项及默认选中值。
///
/// Return:
///
/// ```
/// (
/// Map<年级显示名称: 年级代码>,
/// Map<学院显示名称: 学院代码>,
/// Map<专业显示名称: 专业代码>,
/// String 默认选中的年级代码,
/// String 默认选中的学院代码,
/// String 默认选中的专业代码,
/// )
/// ```
({
  Map<String, String> grades,
  Map<String, String> schools,
  Map<String, String> majors,
  String? selectedGrade,
  String? selectedSchool,
  String? selectedMajor,
}) parseCultivationQueryOptionsFromHtmlZF(String html) {
  final document = parse(html);

  // *****获取年级*****
  final elementGrade = document.getElementById('nj_cx');
  if (elementGrade == null) {
    throw '找不到元素：年级(nj_cx)';
  }
  if (elementGrade.children.isEmpty) {
    throw '可选年级列表为空';
  }
  final int listLengthGrade = elementGrade.children.length;

  /// 所有可选年级
  Map<String, String> grades = {};

  /// 教务系统默认选中的年级（用户的入学年级）
  String? selectedGrade;

  for (int i = 0; i < listLengthGrade; i++) {
    final child = elementGrade.children[i];

    String label = child.innerHtml;
    String? value = child.attributes['value'];

    if ((child.attributes.containsValue('selected') == true)) {
      selectedGrade = value;
    }
    if (label != '' && value != null) {
      grades.addAll({label: value});
    }
  }

  // *****获取学院(school: 学院)*****
  final elementSchool = document.getElementById('jg_id');
  if (elementSchool == null) {
    throw '找不到元素：学院(jg_id)';
  }
  if (elementSchool.children.isEmpty) {
    throw '可选学院列表为空';
  }

  final int listLengthSchool = elementSchool.children.length;

  /// 所有可选学院
  Map<String, String> schools = {};

  /// 教务系统默认选中的学院（用户的所属学院）
  String? selectedSchool;

  for (int i = 0; i < listLengthSchool; i++) {
    final child = elementSchool.children[i];

    String? label = child.innerHtml;
    String? value = child.attributes['value'];

    if ((child.attributes.containsValue('selected') == true)) {
      selectedSchool = value;
    }

    if (label != '' && value != null) {
      schools.addAll({label: value});
    }
  }

  // *****获取专业*****
  final elementMajor = document.getElementById('zyh_id_cx');
  if (elementMajor == null) {
    throw '找不到元素：专业号(zyh_id_cx)';
  }
  if (elementMajor.children.isEmpty) {
    throw '可选专业列表为空';
  }
  final int listLengthMajor = elementMajor.children.length;

  /// 所有可选专业
  Map<String, String> majors = {};

  /// 教务系统默认选中的专业（用户的专业）
  String? selectedMajor;

  for (int i = 0; i < listLengthMajor; i++) {
    final child = elementMajor.children[i];

    String label = child.innerHtml;
    String? value = child.attributes['value'];

    if ((child.attributes.containsValue('selected') == true)) {
      selectedMajor = value;
    }
    if (label != '' && value != null) {
      majors.addAll({label: value});
    }
  }

  return (
    grades: grades,
    schools: schools,
    majors: majors,
    selectedGrade: selectedGrade,
    selectedSchool: selectedSchool,
    selectedMajor: selectedMajor,
  );
}
