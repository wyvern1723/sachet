import 'package:flutter/material.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/get_cacheable_data/get_exam_time.dart';
import 'package:sachet/widgets/homepage_widgets/exam_time_page_qz_widgets/change_semester_dialog.dart';
import 'package:sachet/widgets/homepage_widgets/exam_time_page_qz_widgets/exam_time_card.dart';
import 'package:sachet/widgets/utils_widgets/data_from_cache_or_http.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_qz.dart';

class ExamTimePageQZ extends StatefulWidget {
  /// 考试时间查询页面（强智教务系统）
  const ExamTimePageQZ({super.key});

  @override
  State<ExamTimePageQZ> createState() => _ExamTimePageQZState();
}

class _ExamTimePageQZState extends State<ExamTimePageQZ> {
  late Future getDataFuture;
  bool isDoubleColumn = false;

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      setState(() {
        getDataFuture = getExamTimeDataQZ();
      });
    }
  }

  Future changeSemester() async {
    List? result = await showDialog(
      context: context,
      builder: (context) => ChangeSemesterDialogQZ(),
    );
    if (result != null && result[0] != '') {
      setState(() {
        getDataFuture = getExamTimeDataFromWebQZ(
            semester: result[0], isStoreData: result[1]);
      });
    }
  }

  @override
  void initState() {
    getDataFuture = getExamTimeDataQZ();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('考试时间'),
        actions: [
          IconButton(
            onPressed: () async {
              await changeSemester();
            },
            icon: Icon(Icons.history_outlined),
            tooltip: '更改学期',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isDoubleColumn = !isDoubleColumn;
              });
            },
            icon: isDoubleColumn
                ? Icon(Icons.view_agenda_outlined)
                : Icon(Icons.grid_view_outlined),
            tooltip: '切换视图',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                getDataFuture = getExamTimeDataFromWebQZ(isStoreData: true);
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          )
        ],
      ),
      body: FutureBuilder(
        future: getDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              if (snapshot.error == '登录失效，请重新登录') {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LoginExpiredQZ(onGoBack: (value) => onGoBack(value)),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${snapshot.error}'),
                );
              }
            } else {
              return ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                children: [
                  isDoubleColumn
                      ? _DoubleColumn(data: snapshot.data[0]['data'])
                      : _SingleColumn(data: snapshot.data[0]['data']),
                  SizedBox(height: 4),
                  Text(
                    '查询学期: ${snapshot.data[0]['semester']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DataFromCacheOrHttp(
                      useCache: snapshot.data[1]['isUseCacheData'],
                      updataTime: snapshot.data[1]['lastModifiedTime'],
                    ),
                  )
                ],
              );
            }
          }
          // By default, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _SingleColumn extends StatelessWidget {
  const _SingleColumn({super.key, required this.data});
  final List data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((examInfo) {
        final String? course = examInfo["课程名称"];
        final String? time = examInfo["考试时间"];
        final String? place = examInfo["考场"];
        return ExamTimeCardQZ(
          course: course ?? '',
          time: time ?? '',
          place: place ?? '',
          note: examInfo["备注"] ?? '',
          isHalf: false,
        );
      }).toList(),
    );
  }
}

class _DoubleColumn extends StatelessWidget {
  const _DoubleColumn({
    super.key,
    required this.data,
  });
  final List data;

  @override
  Widget build(BuildContext context) {
    List<Widget> oddList = [];

    List<Widget> evenList = [];

// TODO 这个每点一次切换单/双列就执行一次，应该是这个页面只执行一次
    void _getDataList() {
      List dataList = [];
      dataList = data.map((examInfo) {
        final String? course = examInfo["课程名称"];
        final String? time = examInfo["考试时间"];
        final String? place = examInfo["考场"];

        return ExamTimeCardQZ(
          course: course ?? '',
          time: time ?? '',
          place: place ?? '',
          note: examInfo["备注"] ?? '',
          isHalf: true,
        );
      }).toList();
      int length = data.length;
      for (int i = 0; i < length; i++) {
        if (i.isEven) {
          evenList.add(dataList[i]);
        } else if (i.isOdd) {
          oddList.add(dataList[i]);
        }
      }
    }

    _getDataList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: evenList,
          ),
        ),
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: oddList,
          ),
        ),
      ],
    );
  }
}
