import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/zhengfang_jwxt/response/curriculum_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_cultivation_queryable_majors.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_cultivation_query_options.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_curriculum.dart';
import 'package:sachet/widgets/homepage_widgets/cultivation_page_zf_widgets/change_query_option_dialog.dart';
import 'package:sachet/widgets/homepage_widgets/cultivation_page_zf_widgets/cultivation_page_footer.dart';
import 'package:sachet/widgets/homepage_widgets/cultivation_page_zf_widgets/curriculum_data_table.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class CultivationPlanPageZF extends StatefulWidget {
  /// 培养方案查询页面（正方教务）
  const CultivationPlanPageZF({super.key});

  @override
  State<CultivationPlanPageZF> createState() => _CultivationPlanPageZFState();
}

class _CultivationPlanPageZFState extends State<CultivationPlanPageZF> {
  late Future _future;

  /// 可选年级
  Map<String, String> _grades = {};

  /// 可选学院
  Map<String, String> _schools = {};

  /// 可选专业
  Map<String, String> _majors = {};

  /// 所选的专业下可选的可查询课程信息（培养方案）的专业
  Map<String, String> _queryableMajors = {};

  /// 当前查询的年级
  String _selectedGrade = '';

  /// 当前查询的学院
  String _selectedSchool = '';

  /// 当前查询的专业
  String _selectedMajor = '';

  /// 当前选择的要查询课程信息（培养方案）的专业
  String? _selectedQueryMajor;

  // ignore: unused_field
  List<CurriculumResponseZF>? _curriculumData;

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _future = _getCultivationData(zhengFangUserProvider);
      });
    }
  }

  Future _getQueryOptionsData(
    ZhengFangUserProvider? zhengFangUserProvider,
  ) async {
    final result = await getCultivationQueryOptionsZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );

    _selectedGrade = result.selectedGrade ?? '';
    _selectedSchool = result.selectedSchool ?? '';
    _selectedMajor = result.selectedMajor ?? '';

    _grades = result.grades;
    _schools = result.schools;
    _majors = result.majors;
  }

  Future _getCultivationData(
    ZhengFangUserProvider? zhengFangUserProvider,
  ) async {
    await _getQueryOptionsData(zhengFangUserProvider);

    final queryableMajors = await getCultivationQueryableMajorsZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      gradeId: _selectedGrade,
      schoolId: _selectedSchool,
      majorId: _selectedMajor,
    );

    if (queryableMajors.isEmpty) {
      throw '可查询专业列表为空'; // 没有符合条件记录!
    }

    Map<String, String> queryableMajorsMap = {};

    for (final queryableMajor in queryableMajors) {
      if (queryableMajor.zymc == null || queryableMajor.jxzxjhxxId == null) {
        continue;
      }
      queryableMajorsMap
          .addAll({queryableMajor.zymc!: queryableMajor.jxzxjhxxId!});
    }

    _queryableMajors = queryableMajorsMap;

    if (queryableMajors.length > 1) {
      throw '含有多个可查询专业结果，请选择一项';
    }

    _selectedQueryMajor = queryableMajors[0].jxzxjhxxId;

    final result = await getCurriculumZF(
      cookie: ZhengFangUserProvider.cookie,
      queryMajorId: _selectedQueryMajor!,
      zhengFangUserProvider: zhengFangUserProvider,
    );

    if (mounted) {
      setState(() => _curriculumData = result);
    }

    return result;
  }

  /// 切换查询专业
  Future _changeQueryData(BuildContext context) async {
    final result = await showDialog<
        ({
          String selectedGrade,
          String selectedSchool,
          String selectedMajor,
          String selectedQueryMajor,
          Map<String, String> queryableMajors,
        })?>(
      context: context,
      builder: (context) => ChangeQueryOptionDialog(
        grades: _grades,
        schools: _schools,
        majors: _majors,
        queryableMajors: _queryableMajors,
        selectedGrade: _selectedGrade,
        selectedSchool: _selectedSchool,
        selectedMajor: _selectedMajor,
        selectedQueryableMajor: _selectedQueryMajor,
      ),
    );

    if (!context.mounted) return;

    if (result != null) {
      _selectedGrade = result.selectedGrade;
      _selectedSchool = result.selectedSchool;
      _selectedMajor = result.selectedMajor;
      _selectedQueryMajor = result.selectedQueryMajor;
      _queryableMajors = result.queryableMajors;
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _curriculumData = null;

        _future = getCurriculumZF(
          cookie: ZhengFangUserProvider.cookie,
          zhengFangUserProvider: zhengFangUserProvider,
          queryMajorId: _selectedQueryMajor!,
        ).then((data) {
          if (mounted) {
            setState(() => _curriculumData = data);
          }
          return data;
        }).catchError((error) {
          if (mounted) {
            setState(() => _curriculumData = null);
          }
          throw error;
        });
      });
    }
  }

  String get _displayGrade =>
      _grades.keys.firstWhere((key) => _grades[key] == _selectedGrade,
          orElse: () => _selectedGrade);

  String get _displaySchool =>
      _schools.keys.firstWhere((key) => _schools[key] == _selectedSchool,
          orElse: () => _selectedSchool);

  String get _displayMajor =>
      _majors.keys.firstWhere((key) => _majors[key] == _selectedMajor,
          orElse: () => _selectedMajor);

  String get _displayQueryMajor => _queryableMajors.keys.firstWhere(
      (key) => _queryableMajors[key] == _selectedQueryMajor,
      orElse: () => _selectedQueryMajor ?? '');

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _future = _getCultivationData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('培养方案'),
        actions: [
          IconButton(
            onPressed: () async {
              await _changeQueryData(context);
            },
            icon: Icon(Icons.history_outlined),
            visualDensity: VisualDensity.comfortable,
            tooltip: '切换专业',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            if (snapshot.error ==
                '获取培养方案可选数据失败: Http status code = 302, 可能需要重新登录') {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LoginExpiredZF(onGoBack: (value) => onGoBack(value)),
                ),
              );
            }
            if (snapshot.error == '含有多个可查询专业结果，请选择一项') {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '含有多个可查询专业结果，请选择一项',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedQueryMajor,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '查询专业',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      selectedItemBuilder: (context) => _queryableMajors.entries
                          .map<Widget>(
                            (e) => Text(
                              e.key,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )
                          .toList(),
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
                          setState(() {
                            _selectedQueryMajor = value;
                            final zhengFangUserProvider =
                                context.read<ZhengFangUserProvider>();
                            _future = getCurriculumZF(
                              cookie: ZhengFangUserProvider.cookie,
                              zhengFangUserProvider: zhengFangUserProvider,
                              queryMajorId: value,
                            ).then((data) {
                              if (mounted) {
                                setState(() => _curriculumData = data);
                              }
                              return data;
                            }).catchError((error) {
                              if (mounted) {
                                setState(() => _curriculumData = null);
                              }
                              throw error;
                            });
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 12.0, 8.0, 20.0),
                      child: CultivationPageFooter(
                        queryingGrade: _displayGrade,
                        queryingSchool: _displaySchool,
                        queryingMajor: _displayMajor,
                        queryingQueryMajor: _displayQueryMajor,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 20.0),
                  child: CultivationPageFooter(
                    queryingGrade: _displayGrade,
                    queryingSchool: _displaySchool,
                    queryingMajor: _displayMajor,
                    queryingQueryMajor: _displayQueryMajor,
                  ),
                ),
              ],
            );
          }

          final currisulums = snapshot.data;

          return _CurriculumViewZF(
            curriculums: currisulums,
            queryingGrade: _displayGrade,
            queryingSchool: _displaySchool,
            queryingMajor: _displayMajor,
            queryingQueryMajor: _displayQueryMajor,
          );
        },
      ),
    );
  }
}

/// 课程信息（培养方案） View
class _CurriculumViewZF extends StatelessWidget {
  const _CurriculumViewZF({
    super.key,
    required this.curriculums,
    required this.queryingGrade,
    required this.queryingSchool,
    required this.queryingMajor,
    required this.queryingQueryMajor,
  });
  final List<CurriculumResponseZF> curriculums;
  final String queryingGrade;
  final String queryingSchool;
  final String queryingMajor;
  final String queryingQueryMajor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurriculumDataTable(curriculums: curriculums),

          // Footer, 显示当前查询的专业
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 20.0),
            child: CultivationPageFooter(
              queryingGrade: queryingGrade,
              queryingSchool: queryingSchool,
              queryingMajor: queryingMajor,
              queryingQueryMajor: queryingQueryMajor,
            ),
          ),
        ],
      ),
    );
  }
}
