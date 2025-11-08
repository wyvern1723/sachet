import 'package:flutter/material.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/get_exam_scores.dart';
import 'package:sachet/providers/grade_page_qz_provider.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_qz.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_qz_widgets/gpa_card.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_qz_widgets/help_dialog.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_qz_widgets/grade_details.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_qz_widgets/grade_simple.dart';
import 'package:sachet/widgets/homepage_widgets/grade_page_qz_widgets/semester_selector.dart';
import 'package:provider/provider.dart';

class GradePageQZ extends StatefulWidget {
  /// 成绩查询页面（强智教务）
  const GradePageQZ({super.key});

  @override
  State<GradePageQZ> createState() => _GradePageQZState();
}

class _GradePageQZState extends State<GradePageQZ> {
  bool isSelectingSemester = true; // true 为处于选择学期的状态，false 为查看成绩的状态
  late Future<Map> getDataFuture;

  late Map semestersData;

  Future<Map> getSemestersData() async {
    var data = await getGradeSemesterData();
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
      create: (context) => GradePageQZProvider(),
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
                  builder: (BuildContext context) => HelpDialogQZ(),
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
                              return LoginExpiredQZ(
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
                                Selector<GradePageQZProvider, String>(
                                    selector: (_, gradePageProvider) =>
                                        gradePageProvider.semester,
                                    builder: (context, semester, __) {
                                      return SemesterSelectorQZ(
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
                      GPAWidgetQZ(),

                      const SizedBox(height: 16),

                      //一般视图和详细视图切换的按钮
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          // spacing: 20,
                          children: [
                            //选择学期
                            Selector<GradePageQZProvider, String>(
                                selector: (_, gradePageProvider) =>
                                    gradePageProvider.semester,
                                builder: (context, semester, __) {
                                  return SemesterSelectorQZ(
                                    data: semestersData,
                                    initialSelection: semester,
                                    menuHeight: 400,
                                  );
                                }),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Selector<GradePageQZProvider, bool>(
                                  selector: (_, gradePageProvider) =>
                                      gradePageProvider.isShowDetails,
                                  builder: (context, isShowDetails, __) {
                                    return CheckboxMenuButton(
                                      value: isShowDetails,
                                      onChanged: (bool? value) {
                                        context
                                            .read<GradePageQZProvider>()
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
                      Selector<GradePageQZProvider, bool>(
                        selector: (_, gradePageProvider) =>
                            gradePageProvider.isShowDetails,
                        builder: (context, isShowDetails, __) {
                          return isShowDetails
                              ? GradeDetailsQZ()
                              : GradeSimpleQZ();
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
