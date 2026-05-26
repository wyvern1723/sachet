import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/free_classroom_filter_options.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom_filter_options.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/choose_date.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/choose_week_count.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/choose_weekday.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/choose_session.dart';
// import 'package:sachet/widgets/homepage_widgets/free_classroom_zf_page_widgets/choose_campus.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/choose_teaching_building.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/choose_place_type.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/choose_seat_amount.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class FreeClassroomFilterScreenZF extends StatefulWidget {
  const FreeClassroomFilterScreenZF({super.key, required this.onShowResult});
  final VoidCallback onShowResult;

  @override
  State<FreeClassroomFilterScreenZF> createState() =>
      _FreeClassroomFilterScreenZFState();
}

class _FreeClassroomFilterScreenZFState
    extends State<FreeClassroomFilterScreenZF> {
  late Future<FreeClassroomFilterOptionsZF> future;

  Future<FreeClassroomFilterOptionsZF> getData(
    ZhengFangUserProvider? zhengFangUserProvider,
  ) async {
    // 检查 filterOptions 是否有数据
    final filterOptions =
        context.read<FreeClassroomPageZFProvider>().filterOptions;
    if (filterOptions != null) {
      return filterOptions;
    }

    final result = await getFreeClassroomFilterOptionsZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );
    if (mounted) {
      context.read<FreeClassroomPageZFProvider>().setFilterOptions(result);
    }
    return result;
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      setState(() {
        future = getData(null);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    future = getData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    // return DefaultTabController(
    //   length: 2,
    //   child: Column(
    //     children: [
    //       Container(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         height: kToolbarHeight,
    //         child: TabBar(
    //           tabs: [
    //             Tab(text: '单日'),
    //             Tab(text: '多日'),
    //           ],
    //         ),
    //       ),
    //       Expanded(
    //         child: TabBarView(
    //           children: [
    //             ChooseSingleDate(onShowResult: onShowResult),
    //             ChooseMultiDate(onShowResult: onShowResult),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return FutureBuilder<FreeClassroomFilterOptionsZF>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          if (snapshot.error == "获取可选数据失败: Http status code = 302, 可能需要重新登录") {
            return Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LoginExpiredZF(
                    onGoBack: (value) => onGoBack(value),
                  ),
                ),
              ),
            );
          }
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          );
        }

        // 数据加载成功，传给筛选数据页面
        final filterOptions = snapshot.data!;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Material(
                color: Theme.of(context).useMaterial3
                    ? null
                    : Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceDim,
                child: TabBar(
                  tabs: [
                    Tab(text: '单日'),
                    Tab(text: '多日'),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                ChooseDataView(
                  filterOptions: filterOptions,
                  isSingleDate: true,
                  onShowResult: widget.onShowResult,
                ),
                ChooseDataView(
                  filterOptions: filterOptions,
                  isSingleDate: false,
                  onShowResult: widget.onShowResult,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChooseDataView extends StatefulWidget {
  const ChooseDataView({
    super.key,
    required this.filterOptions,
    required this.isSingleDate,
    required this.onShowResult,
  });
  final FreeClassroomFilterOptionsZF filterOptions;

  /// 单日/多日, true => 单日, false => 多日
  final bool isSingleDate;
  final VoidCallback onShowResult;

  @override
  State<ChooseDataView> createState() => _ChooseDataViewState();
}

class _ChooseDataViewState extends State<ChooseDataView> {
  @override
  void initState() {
    super.initState();
    context.read<FreeClassroomPageZFProvider>().resetSelectedWeekCounts();
    context.read<FreeClassroomPageZFProvider>().resetSelectedWeekdays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 选择日期
                if (widget.isSingleDate) ChooseDate(),

                // 选择周次
                ChooseWeekCount(isSingleChoice: widget.isSingleDate),

                // 星期
                ChooseWeekday(isSingleChoice: widget.isSingleDate),

                // 节次
                ChooseSession(),

                // 选择校区
                // 才发现"校区"选择"兴湘学院"查询是没有数据的，所以不用选择校区🤡
                // ChooseCampus(),

                // 选择教学楼
                ChooseTeachingBuilding(
                  filterOptions: widget.filterOptions.teachingBuildingOptions,
                  selectedOption: widget.filterOptions.selectedTeachingBuilding,
                ),

                // 选择场地类别
                ChoosePlaceType(
                  filterOptions: widget.filterOptions.placeTypeOptions,
                  selectedOption: widget.filterOptions.selectedPlaceType,
                ),

                // 选择座位数
                ChooseSeatAmount(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          try {
            // 检查输入是否合法
            context.read<FreeClassroomPageZFProvider>().validateSelectedData();
            // 如果合法,进入结果页面
            widget.onShowResult();
          } catch (e) {
            // 不合法,提示哪个输入不合法
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('请选择$e'),
                content: Text('请选择$e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('确认'),
                  )
                ],
              ),
            );
          }
        },
        icon: const Text('查询'),
        // label: const Icon(Icons.search),
        label: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
