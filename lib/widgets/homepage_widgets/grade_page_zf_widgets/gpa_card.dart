import 'package:flutter/material.dart';
import 'package:sachet/models/gpa_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_gpa.dart';
import 'package:provider/provider.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class GPACardZF extends StatefulWidget {
  /// 成绩查询页面（正方教务）的 GPA Card
  const GPACardZF({
    super.key,
    required this.startSemester,
    required this.endSemester,
    required this.courseType,
  });

  /// 起始学年学期，如 "202503", "202512"
  final String startSemester;

  /// 终止学年学期，如 "202503", "202512"
  final String endSemester;

  /// 课程属性. 全部: "", 必修: "bx", 选修: "xx"
  final String courseType;
  @override
  State<GPACardZF> createState() => _GPACardZFState();
}

class _GPACardZFState extends State<GPACardZF> {
  late Future _future;

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _future = _getGPAData(zhengFangUserProvider);
      });
    }
  }

  Future _getGPAData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await getGPAZF(
      cookie: ZhengFangUserProvider.cookie,
      startSemester: widget.startSemester,
      endSemester: widget.endSemester,
      courseType: widget.courseType,
      zhengFangUserProvider: zhengFangUserProvider,
    );
    return result;
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _future = _getGPAData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    '获取绩点排名数据中...',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  )
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          if (snapshot.error ==
              "获取绩点排名数据失败: Http status code = 302, 可能需要重新登录") {
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

        final gpaResponseZF = snapshot.data;
        if (gpaResponseZF == null) {
          return Text(
            '数据为空',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return _ResultGPACard(gpaResponseZF: gpaResponseZF);
      },
    );
  }
}

class _ResultGPACard extends StatelessWidget {
  final GpaResponseZF gpaResponseZF;

  const _ResultGPACard({super.key, required this.gpaResponseZF});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.secondaryContainer,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPA: ${gpaResponseZF.pjxfjd}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),

                    //平均成绩
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '平均成绩: ${gpaResponseZF.pjcj}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2),

                    //班级排名
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group,
                          color: colorScheme.onSecondaryContainer,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '班级排名: ${gpaResponseZF.jdbjpm}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),

                    //年级排名
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.groups,
                          color: colorScheme.onSecondaryContainer,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '专业排名: ${gpaResponseZF.jdnjzypm}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
