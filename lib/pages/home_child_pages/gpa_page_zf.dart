import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/gpa_page_zf_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_gpa_semesters.dart';
import 'package:sachet/widgets/homepage_widgets/gpa_page_zf_widgets/course_type_selector.dart';
import 'package:sachet/widgets/homepage_widgets/gpa_page_zf_widgets/end_semester_year_selector.dart';
import 'package:sachet/widgets/homepage_widgets/gpa_page_zf_widgets/start_semester_year_selector.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_zf_widgets/gpa_card.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class GPAPageZF extends StatelessWidget {
  const GPAPageZF({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GPAPageZFProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('绩点排名')),
        body: Selector<GPAPageZFProvider, bool>(
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
    final result = await getGPASemestersZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );
    context
        .read<GPAPageZFProvider>()
        .setStartSemestersYears(result.startSemesters);
    context.read<GPAPageZFProvider>().setEndSemestersYears(result.endSemesters);
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: getDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          '获取可查询学期中...',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        )
                      ],
                    ),
                  );
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    StartSemesterSelectorZF(),
                    SizedBox(height: 10),
                    EndSemesterSelectorZF(),
                    SizedBox(height: 10),
                    CourseTypeSelectorZF(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        context
                            .read<GPAPageZFProvider>()
                            .setIsSelectingSemester(false);
                      },
                      child: Text('查询'),
                    ),
                    SizedBox(height: 100),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  /// 显示结果
  const _ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: StartSemesterSelectorZF(),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 0,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: EndSemesterSelectorZF(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CourseTypeSelectorZF(width: 100),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Selector<
                GPAPageZFProvider,
                ({
                  String startSemester,
                  String endSemester,
                  String courseType
                })>(
              selector: (_, provider) => (
                startSemester: provider.selectedStartSemester,
                endSemester: provider.selectedEndSemester,
                courseType: provider.courseType,
              ),
              builder: (_, data, ___) {
                return GPACardZF(
                  key: ValueKey(
                      "${data.startSemester}_${data.endSemester}_${data.courseType}"),
                  startSemester: data.startSemester,
                  endSemester: data.endSemester,
                  courseType: data.courseType,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
