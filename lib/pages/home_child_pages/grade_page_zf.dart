import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/grade_page_zf_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_grade.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_grade_semesters_and_alert_text.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_qz_widgets/item_filter_dialog.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_zf_widgets/alert_text.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_zf_widgets/grade_table.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_zf_widgets/semester_index_selector.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_zf_widgets/semester_year_selector.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class GradePageZF extends StatelessWidget {
  const GradePageZF({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GradePageZFProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('成绩查询')),
        body: Selector<GradePageZFProvider, bool>(
            selector: (_, provider) => provider.isSelectingSemester,
            builder: (context, isSelectingSemester, __) {
              if (isSelectingSemester) {
                return _QueryView();
              } else {
                return _ResultView();
              }
            }),
      ),
    );
  }
}

class _QueryView extends StatefulWidget {
  /// 获取可选学期及让用户选择学期
  const _QueryView({super.key});

  @override
  State<_QueryView> createState() => _QueryViewState();
}

class _QueryViewState extends State<_QueryView> {
  late Future getDataFuture;

  Future _getSemestersData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await getGradeSemestersAndAlertTextZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );
    final selectedSemesterYear = result.currentSemesterYear;
    if (selectedSemesterYear != null) {
      context
          .read<GradePageZFProvider>()
          .changeSemesterYear(selectedSemesterYear);
    }
    final selectedSemesterIndex = result.currentSemesterIndex;

    if (selectedSemesterIndex != null) {
      context
          .read<GradePageZFProvider>()
          .changeSemesterIndex(selectedSemesterIndex);
    }
    context
        .read<GradePageZFProvider>()
        .setSemestersYears(result.semestersYears);
    context.read<GradePageZFProvider>().setAlertText(result.alertTexts);
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

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    getDataFuture = _getSemestersData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                      SemesterYearSelectorZF(),
                      SemesterIndexSelectorZF(),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      context
                          .read<GradePageZFProvider>()
                          .setIsSelectingSemester(false);
                    },
                    child: Text('查询'),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatefulWidget {
  /// 筛选显示字段的按钮
  const _FilterButton({super.key});

  @override
  State<_FilterButton> createState() => __FilterButtonState();
}

class __FilterButtonState extends State<_FilterButton> {
  void showFilterDialog() async {
    List<String> items = context.read<GradePageZFProvider>().items;
    List<String> selectedItems =
        context.read<GradePageZFProvider>().selectedItems;

    List<List<String>>? results = await showDialog(
      context: context,
      builder: (BuildContext context) => ItemFilterDialogQZ(
        items: items,
        selectedItems: selectedItems,
      ),
    );
    if (results != null) {
      // 新选择的要显示的 selectedItems，（经过 List.add、List.remove,顺序会乱）
      List<String> newSelectedItems = results[0];

      // （可能）经过重新排序的 items
      List<String> reorderedItems = results[1];

      // 对 newSelectedItems 根据 reorderedItems 的顺序排序
      // e.g.
      // newSelectedItems = [[课程名称, 学分, 平时成绩, 总成绩, 考核方式, 期末成绩],
      // reorderedItems = [开课学期, 课程名称, 学分, 平时成绩, 期末成绩, 总成绩, 总学时, 考核方式, 课程属性, 课程性质]]
      // 经过下面的处理 ==>
      // newSelectedItems = [课程名称, 学分, 平时成绩, 期末成绩, 总成绩, 考核方式]
      newSelectedItems.sort((a, b) =>
          reorderedItems.indexOf(a).compareTo(reorderedItems.indexOf(b)));
      context.read<GradePageZFProvider>().updateSelectedItems(newSelectedItems);
      context.read<GradePageZFProvider>().updateItems(reorderedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      onPressed: showFilterDialog,
      icon: Icon(Icons.filter_list_outlined),
      label: Text('筛选'),
    );
  }
}

class _ResultView extends StatelessWidget {
  /// 显示成绩结果（上面是学期选择，下面是成绩表）
  const _ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 成绩查询页面的红色提醒文字（如未完成评教的信息等）
            AlertTextZF(),

            Wrap(
              spacing: 8,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                SemesterYearSelectorZF(),
                SemesterIndexSelectorZF(),
                _FilterButton(),
              ],
            ),

            Selector<GradePageZFProvider, (String, String)>(
                selector: (_, provider) => (
                      provider.selectedSemesterYear,
                      provider.selectedSemesterIndex,
                    ),
                builder: (_, data, ___) {
                  return _GradeView(
                    key: ValueKey("${data.$1}_${data.$2}"),
                    semesterYear: data.$1,
                    semesterIndex: data.$2,
                  );
                }),
          ],
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
