import 'package:flutter/material.dart';
import 'package:sachet/services/get_jwxt_data/process_data/get_exam_scores.dart';
import 'package:sachet/providers/grade_page_provider.dart';
import 'package:sachet/widgets/utils_widgets/login_expired.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_widgets/gpa_card.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_widgets/help_dialog.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_widgets/grade_details.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_widgets/grade_simple.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_widgets/semester_selector.dart';
import 'package:provider/provider.dart';

class GradePage extends StatefulWidget {
  const GradePage({super.key});

  @override
  State<GradePage> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  bool isSelectingSemester = true; // true 为处于选择学期的状态，false 为查看成绩的状态
  late Future<Map> getDataFuture;

  late Map semestersData;

  Future<Map> getSemestersData() async {
    var data = await getGradeSemesterData();
    // await Future.delayed(Duration(milliseconds: 500));
    // var data = mapData;
    return data;
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      setState(() {
        getDataFuture = getSemestersData();
      });
    }
  }

  @override
  void initState() {
    getDataFuture = getSemestersData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GradePageProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('成绩查询'),
          actions: [
            IconButton(
              icon: Icon(Icons.help),
              tooltip: '说明',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => HelpDialog(),
                );
              },
            )
          ],
        ),
        body: isSelectingSemester
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                      future: getDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            if (snapshot.error == '登录失效，请重新登录') {
                              return LoginExpired(
                                onGoBack: (value) => onGoBack(value),
                              );
                            } else {
                              return Text('${snapshot.error}');
                            }
                          } else {
                            semestersData = snapshot.data ?? {'': ''};
                            return Column(
                              children: [
                                SizedBox(height: 20),
                                Selector<GradePageProvider, String>(
                                    selector: (_, gradePageProvider) =>
                                        gradePageProvider.semester,
                                    builder: (context, semester, __) {
                                      return SemesterSelector(
                                        data: semestersData,
                                        initialSelection: semester,
                                        menuHeight: 400,
                                      );
                                    }),
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
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //GPA(绩点)
                      GPAWidget(),

                      const SizedBox(height: 16),

                      //一般视图和详细视图切换的按钮
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 20,
                          children: [
                            //选择学期
                            Selector<GradePageProvider, String>(
                                selector: (_, gradePageProvider) =>
                                    gradePageProvider.semester,
                                builder: (context, semester, __) {
                                  return SemesterSelector(
                                    data: semestersData,
                                    initialSelection: semester,
                                    menuHeight: 400,
                                  );
                                }),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Selector<GradePageProvider, bool>(
                                  selector: (_, gradePageProvider) =>
                                      gradePageProvider.isShowDetails,
                                  builder: (context, isShowDetails, __) {
                                    return CheckboxMenuButton(
                                      value: isShowDetails,
                                      onChanged: (bool? value) {
                                        context
                                            .read<GradePageProvider>()
                                            .changeIsShowDetails();
                                      },
                                      child: Text('显示详细信息'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 根据 isShowDetails （是否显示详细信息）决定显示 GradeSimple 成绩信息（简单）或 GradeDetails 成绩信息（详细）
                      Selector<GradePageProvider, bool>(
                        selector: (_, gradePageProvider) =>
                            gradePageProvider.isShowDetails,
                        builder: (context, isShowDetails, __) {
                          return isShowDetails ? GradeDetails() : GradeSimple();
                        },
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
