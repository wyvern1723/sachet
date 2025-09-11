import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:sachet/models/free_classroom_filter_options.dart';

/// 获取空闲教室可选的数据
FreeClassroomFilterOptionsZF parseFreeClassroomFilterOptionsZF(String html) {
  final document = parse(html);

  // 所有要解析的元素 ID 列表
  final semesterElement = document.getElementById('dm_cx');
  final buildingElement = document.getElementById('lh');
  final placeTypeElement = document.getElementById('cdlb_id');

  if (semesterElement == null) throw '找不到元素: 学年学期';
  if (buildingElement == null) throw '找不到元素: 楼号';
  if (placeTypeElement == null) throw '找不到元素: 场地类别';

  final semesterData = _parseSelectOptions(semesterElement);
  final buildingData = _parseSelectOptions(buildingElement);
  final placeTypeData = _parseSelectOptions(placeTypeElement);

  return FreeClassroomFilterOptionsZF(
    semesterOptions: semesterData.options,
    selectedSemester: semesterData.selectedValue,
    teachingBuildingOptions: buildingData.options,
    selectedTeachingBuilding: buildingData.selectedValue,
    placeTypeOptions: placeTypeData.options,
    selectedPlaceType: placeTypeData.selectedValue,
  );
}

// 通用解析函数：传入一个 select 元素，返回选项列表 + 当前选中值
({
  Map<String, String> options,
  String? selectedValue,
}) _parseSelectOptions(Element? element) {
  final options = <String, String>{};
  String? selectedValue;

  if (element == null) return (options: options, selectedValue: null);
  if (element.children.isEmpty) return (options: options, selectedValue: null);

  for (final child in element.children) {
    final String label = child.innerHtml.trim();
    final String? value = child.attributes['value']?.trim();

    if (value != null) {
      options[label] = value;
    }

    // 检查是否选中（selected="selected"）
    if (child.attributes.containsValue('selected')) {
      selectedValue = value;
    }
  }

  return (options: options, selectedValue: selectedValue);
}
