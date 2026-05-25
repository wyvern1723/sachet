import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_cultivation_queryable_majors.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_cultivation_school_majors.dart';

class ChangeQueryOptionDialog extends StatefulWidget {
  const ChangeQueryOptionDialog({
    super.key,
    required this.grades,
    required this.schools,
    required this.majors,
    required this.queryableMajors,
    required this.selectedGrade,
    required this.selectedSchool,
    required this.selectedMajor,
    required this.selectedQueryableMajor,
  });
  final Map<String, String> grades;
  final Map<String, String> schools;
  final Map<String, String> majors;
  final Map<String, String> queryableMajors;

  final String selectedGrade;
  final String selectedSchool;
  final String selectedMajor;
  final String? selectedQueryableMajor;

  @override
  State<ChangeQueryOptionDialog> createState() =>
      _ChangeQueryOptionDialogState();
}

class _ChangeQueryOptionDialogState extends State<ChangeQueryOptionDialog> {
  Map<String, String> _majors = {};
  Map<String, String> _queryableMajors = {};

  String _selectedGrade = '';
  String _selectedSchool = '';
  String? _selectedMajor;
  String? _selectedQueryMajor;

  String? _queryableMajorsErrorText;
  String? _majorsErrorText;

  Future _getCurrentSchoolMajors() async {
    try {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      final schoolMajors = await getCultivationSchoolMajorsZF(
        cookie: ZhengFangUserProvider.cookie,
        zhengFangUserProvider: zhengFangUserProvider,
        shoolId: widget.selectedSchool,
      );

      if (!mounted) return;

      final Map<String, String> schoolMajorsMap = {'全部': ''};
      for (final schoolMajor in schoolMajors) {
        if (schoolMajor.zymc == null || schoolMajor.zyhId == null) {
          continue;
        }
        schoolMajorsMap.addAll({schoolMajor.zymc!: schoolMajor.zyhId!});
      }
      setState(() => _majors = schoolMajorsMap);
      // 如果当前选择的专业不在获取的列表中，重置为第一项
      if (!_majors.containsValue(_selectedMajor)) {
        setState(() => _selectedMajor = _majors.values.first);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _majorsErrorText = '初始化专业失败: ${e.toString()}');
    }
  }

  /// 切换年级
  Future _onUpdateGrade(BuildContext context, String grade) async {
    setState(() => _selectedGrade = grade);
    await _onUpdateMajor(context, _selectedMajor ?? '');
  }

  /// 切换学院
  Future _onUpdateSchool(BuildContext context, String schoolId) async {
    setState(() {
      _selectedSchool = schoolId;
      _selectedMajor = null;
      _majors = {};
      _selectedQueryMajor = null;
      _queryableMajors = {};
      _majorsErrorText = null;
      _queryableMajorsErrorText = null;
    });

    try {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      final schoolMajors = await getCultivationSchoolMajorsZF(
        cookie: ZhengFangUserProvider.cookie,
        zhengFangUserProvider: zhengFangUserProvider,
        shoolId: schoolId,
      );

      if (!context.mounted) return;

      final Map<String, String> schoolMajorsMap = {'全部': ''};
      for (final schoolMajor in schoolMajors) {
        if (schoolMajor.zymc == null || schoolMajor.zyhId == null) {
          continue;
        }
        schoolMajorsMap.addAll({schoolMajor.zymc!: schoolMajor.zyhId!});
      }

      setState(() {
        _majors = schoolMajorsMap;
        _selectedMajor = '';
      });

      await _onUpdateMajor(context, _selectedMajor ?? '');
    } catch (e) {
      if (!context.mounted) return;

      setState(() {
        _majorsErrorText =
            e.toString() == '此学院下属专业信息为空' ? '此学院下未查询到专业，请重新选择学院' : e.toString();
      });
    }
  }

  /// 切换专业
  Future _onUpdateMajor(BuildContext context, String majorId) async {
    setState(() {
      _selectedMajor = majorId;
      _selectedQueryMajor = null;
      _queryableMajors = {};
      _queryableMajorsErrorText = null;
    });
    try {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      final queryableMajors = await getCultivationQueryableMajorsZF(
        cookie: ZhengFangUserProvider.cookie,
        zhengFangUserProvider: zhengFangUserProvider,
        gradeId: _selectedGrade,
        schoolId: _selectedSchool,
        majorId: majorId,
      );

      if (!context.mounted) return;

      final Map<String, String> queryableMajorsMap = {};
      for (final queryableMajor in queryableMajors) {
        if (queryableMajor.zymc == null || queryableMajor.jxzxjhxxId == null) {
          continue;
        }
        queryableMajorsMap
            .addAll({queryableMajor.zymc!: queryableMajor.jxzxjhxxId!});
      }

      setState(() {
        _queryableMajors = queryableMajorsMap;
        _selectedQueryMajor = queryableMajorsMap.values.first;
      });
    } catch (e) {
      if (!context.mounted) return;

      setState(() {
        _queryableMajorsErrorText = e.toString() == '可查询专业为空，没有符合条件记录!'
            ? '此专业下未查询到可查询课程信息的专业，请重新选择专业（建议在上一栏"专业"选择"全部"，然后在此项选择你的专业）'
            : e.toString();
      });
    }
  }

  /// 更新要查询的专业
  void _onUpdateQueryMajor(String queryMajorId) {
    setState(() => _selectedQueryMajor = queryMajorId);
  }

  @override
  void initState() {
    super.initState();
    _majors = widget.majors;
    _queryableMajors = widget.queryableMajors;
    _selectedGrade = widget.selectedGrade;
    _selectedSchool = widget.selectedSchool;
    _selectedMajor = widget.selectedMajor;
    _selectedQueryMajor = widget.selectedQueryableMajor;

    _getCurrentSchoolMajors();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择专业'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: '年级',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: widget.grades.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.value,
                        child: Text(e.key),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    _onUpdateGrade(context, value);
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSchool,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: '学院',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                selectedItemBuilder: (context) =>
                    _buildSelectedItems(widget.schools),
                items: widget.schools.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.value,
                        child: Text(e.key),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) async {
                  if (value != null) {
                    _onUpdateSchool(context, value);
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMajor,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: '专业',
                  errorText: _majorsErrorText,
                  errorMaxLines: 100,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                selectedItemBuilder: (context) => _buildSelectedItems(_majors),
                items: _majors.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.value,
                        child: Text(e.key),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) async {
                  if (value != null) {
                    _onUpdateMajor(context, value);
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedQueryMajor,
                isExpanded: true,
                decoration: InputDecoration(
                  errorText: _queryableMajorsErrorText,
                  errorMaxLines: 100,
                  labelText: '查询专业',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                selectedItemBuilder: (context) =>
                    _buildSelectedItems(_queryableMajors),
                items: _queryableMajors.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.value,
                        child: Text(e.key),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    _onUpdateQueryMajor(value);
                  }
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _selectedQueryMajor == null
              ? null
              : () => Navigator.pop(
                    context,
                    (
                      selectedGrade: _selectedGrade,
                      selectedSchool: _selectedSchool,
                      selectedMajor: _selectedMajor,
                      selectedQueryMajor: _selectedQueryMajor,
                      queryableMajors: _queryableMajors,
                    ),
                  ),
          child: const Text('确认'),
        )
      ],
    );
  }

  /// 提取的通用 Dropdown 选中项 Text Builder
  List<Widget> _buildSelectedItems(Map<String, String> map) {
    return map.entries.map<Widget>((e) {
      return Text(
        e.key,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }).toList();
  }
}
