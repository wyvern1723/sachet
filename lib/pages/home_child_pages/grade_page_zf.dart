import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_grade.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_grade_semesters.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_zf_widgets/grade_table.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class GradePageZF extends StatefulWidget {
  const GradePageZF({super.key});

  @override
  State<GradePageZF> createState() => _GradePageZFState();
}

class _GradePageZFState extends State<GradePageZF> {
  bool isSelectingSemester = true; // true 为处于选择学期的状态，false 为查看成绩的状态
  late Future getDataFuture;

  Map _semestersYears = {};
  String? _selectedSemesterYear;
  final Map _semesterIndexes = {
    "全部": "",
    "1": "3",
    "2": "12",
    "3": "16",
  };
  String? _selectedSemesterIndex;

  /// 是否在 学年 DropDownMenu 显示 ErrorTexy
  bool _isShowSemesterYearDropDownMenuError = false;

  /// 是否在 学期 DropDownMenu 显示 ErrorTexy
  bool _isShowSemesterIndexDropDownMenuError = false;

  Future _getSemestersData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await getGradeSemestersZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );
    _semestersYears = result.semestersYears;
    _selectedSemesterYear = result.currentSemesterYear;
    _selectedSemesterIndex = result.currentSemesterIndex;
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        getDataFuture = _getSemestersData(zhengFangUserProvider);
      });
    }
  }

  void _chooseSemesterYear(String? semester) {
    if (semester != null) {
      setState(() {
        _selectedSemesterYear = semester;
      });
      if (_isShowSemesterYearDropDownMenuError == true) {
        setState(() {
          _isShowSemesterYearDropDownMenuError = false;
        });
      }
    }
  }

  void _chooseSemesterIndex(String? semester) {
    if (semester != null) {
      setState(() {
        _selectedSemesterIndex = semester;
      });
      if (_isShowSemesterIndexDropDownMenuError == true) {
        setState(() {
          _isShowSemesterIndexDropDownMenuError = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    getDataFuture = _getSemestersData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成绩查询'),
      ),
      body: isSelectingSemester
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: getDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        if (snapshot.error ==
                            "获取可查询学期数据失败: Http status code = 302, 可能需要重新登录") {
                          return Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: LoginExpiredZF(
                                onGoBack: (value) => onGoBack(value),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runAlignment: WrapAlignment.center,
                            children: [
                              DropdownMenu<String>(
                                width: 160,
                                menuHeight: 400,
                                errorText: _isShowSemesterYearDropDownMenuError
                                    ? "请选择一项"
                                    : null,
                                initialSelection: _selectedSemesterYear,
                                requestFocusOnTap: false,
                                label: const Text('学年'),
                                onSelected: (String? semester) {
                                  if (semester != null) {
                                    _selectedSemesterYear = semester;
                                    if (_isShowSemesterYearDropDownMenuError ==
                                        true) {
                                      setState(() {
                                        _isShowSemesterYearDropDownMenuError =
                                            false;
                                      });
                                    }
                                  }
                                },
                                dropdownMenuEntries: _semestersYears.entries
                                    .map((e) => DropdownMenuEntry<String>(
                                        value: e.value, label: e.key))
                                    .toList(),
                              ),
                              DropdownMenu<String>(
                                width: 120,
                                menuHeight: 400,
                                errorText: _isShowSemesterIndexDropDownMenuError
                                    ? "请选择一项"
                                    : null,
                                initialSelection: _selectedSemesterIndex,
                                requestFocusOnTap: false,
                                label: const Text('学期'),
                                onSelected: (String? semester) {
                                  if (semester != null) {
                                    _selectedSemesterIndex = semester;
                                    if (_isShowSemesterIndexDropDownMenuError ==
                                        true) {
                                      setState(() {
                                        _isShowSemesterIndexDropDownMenuError =
                                            false;
                                      });
                                    }
                                  }
                                },
                                dropdownMenuEntries: _semesterIndexes.entries
                                    .map((e) => DropdownMenuEntry<String>(
                                        value: e.value, label: e.key))
                                    .toList(),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                isSelectingSemester = false;
                              });
                            },
                            child: Text('查询'),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        DropdownMenu<String>(
                          width: 160,
                          menuHeight: 400,
                          errorText: _isShowSemesterYearDropDownMenuError
                              ? "请选择一项"
                              : null,
                          initialSelection: _selectedSemesterYear,
                          requestFocusOnTap: false,
                          label: const Text('学年'),
                          onSelected: _chooseSemesterYear,
                          dropdownMenuEntries: _semestersYears.entries
                              .map((e) => DropdownMenuEntry<String>(
                                  value: e.value, label: e.key))
                              .toList(),
                        ),
                        DropdownMenu<String>(
                          width: 120,
                          menuHeight: 400,
                          errorText: _isShowSemesterIndexDropDownMenuError
                              ? "请选择一项"
                              : null,
                          initialSelection: _selectedSemesterIndex,
                          requestFocusOnTap: false,
                          label: const Text('学期'),
                          onSelected: _chooseSemesterIndex,
                          dropdownMenuEntries: _semesterIndexes.entries
                              .map((e) => DropdownMenuEntry<String>(
                                  value: e.value, label: e.key))
                              .toList(),
                        ),
                      ],
                    ),
                    _GradeView(
                      key: ValueKey(
                          '${_selectedSemesterYear}_${_selectedSemesterIndex}'),
                      semesterYear: _selectedSemesterYear ?? '',
                      semesterIndex: _selectedSemesterIndex ?? '',
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ),
    );
  }
}

class _GradeView extends StatefulWidget {
  /// xnm 学年名，如 '2025'=> 指 2025-2026 学年
  final String semesterYear;

  /// xqm 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期, "" => 全部
  final String semesterIndex;

  const _GradeView({
    super.key,
    required this.semesterYear,
    required this.semesterIndex,
  });

  @override
  State<_GradeView> createState() => _GradeViewState();
}

class _GradeViewState extends State<_GradeView> {
  late Future _dataFuture;

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _dataFuture = _getGradeData(zhengFangUserProvider);
      });
    }
  }

  Future _getGradeData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await getGradeZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      semesterYear: widget.semesterYear,
      semesterIndex: widget.semesterIndex,
    );
    return result;
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _dataFuture = _getGradeData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
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
          if (snapshot.error == "获取成绩数据失败: Http status code = 302, 可能需要重新登录") {
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LoginExpiredZF(
                  onGoBack: (value) => onGoBack(value),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        final gradeData = snapshot.data;
        return Column(
          children: [
            SizedBox(height: 20),
            GradeTableZF(gradeData: gradeData),
          ],
        );
      },
    );
  }
}
