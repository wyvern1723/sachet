import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sachet/providers/gpa_page_zf_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/zhengfang_jwxt.dart';
import 'package:sachet/widgets/homepage_widgets/gpa_page_zf_widgets/course_type_selector.dart';
import 'package:sachet/widgets/homepage_widgets/gpa_page_zf_widgets/end_semester_year_selector.dart';
import 'package:sachet/widgets/homepage_widgets/gpa_page_zf_widgets/start_semester_year_selector.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_zf_widgets/gpa_card.dart';
import 'package:sachet/widgets/utils_widgets/error_with_retry_widget.dart';
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
  const _QueryView();

  @override
  State<_QueryView> createState() => _QueryViewState();
}

class _QueryViewState extends State<_QueryView> {
  late Future getDataFuture;

  Future _getSemestersData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await ZhengFangJwxt.gpa.getGPASemesters(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );

    if (!mounted) return;

    context
        .read<GPAPageZFProvider>()
        .setStartSemestersYears(result.startSemesters);
    context.read<GPAPageZFProvider>().setEndSemestersYears(result.endSemesters);
  }

  void _onRetry() {
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    setState(() {
      getDataFuture = _getSemestersData(zhengFangUserProvider);
    });
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    getDataFuture = _getSemestersData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: getDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    '获取可查询学期中...',
                    style: TextStyle(color: colorScheme.primary),
                  )
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          if (snapshot.error ==
              "获取可查询学期数据失败: Http status code = 302, 可能需要重新登录") {
            return LoginExpiredZF(onRetry: _onRetry);
          }
          return ErrorWithRetryWidget(
            text: '${snapshot.error}',
            onRetry: _onRetry,
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 52),
                StartSemesterSelectorZF(),
                SizedBox(height: 32),
                EndSemesterSelectorZF(),
                SizedBox(height: 32),
                CourseTypeSelectorZF(),
                SizedBox(height: 52),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 28),
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
            ),
          ),
        );
      },
    );
  }
}

class _ResultView extends StatelessWidget {
  /// 显示结果
  const _ResultView();

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: StartSemesterSelectorZF(),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: EndSemesterSelectorZF(),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CourseTypeSelectorZF(),
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
                  isShowCourseTypeSegmentedControl: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
