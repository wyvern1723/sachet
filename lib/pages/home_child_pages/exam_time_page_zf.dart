import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/exam_time_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_exam_time.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_exam_time_semesters.dart';
import 'package:sachet/widgets/homepage_widgets/exam_time_page_zf_widgets/exam_time_card.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class ExamTimePageZF extends StatefulWidget {
  /// 考试时间查询页面（正方教务）
  const ExamTimePageZF({super.key});

  @override
  State<ExamTimePageZF> createState() => _ExamTimePageZFState();
}

class _ExamTimePageZFState extends State<ExamTimePageZF> {
  late Future _future;

  /// 当前查询的学年
  String _selectedSemesterYear = '';

  /// 当前查询的学期
  String _selectedSemesterIndex = '';

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _future = _getExamTimeData(zhengFangUserProvider);
      });
    }
  }

  Future _getSemestersData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await getExamTimeSemestersZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );

    _selectedSemesterYear = result.currentSemesterYear ?? '';
    _selectedSemesterIndex = result.currentSemesterIndex ?? '';
  }

  Future _getExamTimeData(ZhengFangUserProvider? zhengFangUserProvider) async {
    await _getSemestersData(zhengFangUserProvider);

    final result = await getExamTimeZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      semesterYear: _selectedSemesterYear,
      semesterIndex: _selectedSemesterIndex,
    );
    return result;
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _future = _getExamTimeData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("考试时间")),
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
                "获取可查询学期数据失败: Http status code = 302, 可能需要重新登录") {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LoginExpiredZF(onGoBack: (value) => onGoBack(value)),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final examTimeData = snapshot.data;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: _ExamTimeViewZF(examTimeData: examTimeData),
          );
        },
      ),
    );
  }
}

/// 考试时间结果 View
class _ExamTimeViewZF extends StatelessWidget {
  const _ExamTimeViewZF({super.key, required this.examTimeData});
  final List<ExamTimeZF> examTimeData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...examTimeData.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ExamTimeCardZF(examTime: e),
          );
        }),
      ],
    );
  }
}
