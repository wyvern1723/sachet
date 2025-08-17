import 'package:flutter/material.dart';
import 'package:sachet/services/get_jwxt_data/get_cacheable_data/get_cultivate_plan.dart';
import 'package:sachet/widgets/utils_widgets/data_from_cache_or_http.dart';
import 'package:sachet/widgets/utils_widgets/login_expired.dart';

class CultivatePage extends StatefulWidget {
  const CultivatePage({super.key});

  @override
  State<CultivatePage> createState() => _CultivatePageState();
}

class _CultivatePageState extends State<CultivatePage> {
  late Future<List?> getDataFuture;

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      setState(() {
        getDataFuture = getCultivatePlanDataFromWeb();
      });
    }
  }

  @override
  void initState() {
    getDataFuture = getCultivatePlanData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('培养方案'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                getDataFuture = getCultivatePlanDataFromWeb();
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          )
        ],
      ),
      body: FutureBuilder<List?>(
        future: getDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              if (snapshot.error == '登录失效，请重新登录') {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LoginExpired(onGoBack: (value) => onGoBack(value)),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${snapshot.error}'),
                );
              }
            } else {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: CultivatePlanTable(
                  listData: snapshot.data![0],
                  sourceData: snapshot.data![1],
                ),
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

List<String> tableHead = ['序号', '开设学期', '课程名称', '课程类别', '总学时', '学分', '考核方式'];

class CultivatePlanTable extends StatefulWidget {
  const CultivatePlanTable(
      {super.key, required this.listData, required this.sourceData});
  final List listData;
  final List sourceData;

  @override
  State<CultivatePlanTable> createState() => _CultivatePlanTableState();
}

class _CultivatePlanTableState extends State<CultivatePlanTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
            6: FlexColumnWidth(1),
          },
          // defaultColumnWidth: FractionColumnWidth(0.17),
          border: TableBorder.all(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              children: [
                ...List.generate(
                  7,
                  (index) => TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        tableHead[index],
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...List.generate(
              widget.listData.length,
              (index1) => TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                children: [
                  ...List.generate(
                    7,
                    (index2) => TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          widget.listData[index1].entries
                              .elementAt(index2)
                              .value,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: DataFromCacheOrHttp(
            useCache: widget.sourceData[0],
            updataTime: widget.sourceData[1],
          ),
        )
      ],
    );
  }
}
