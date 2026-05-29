import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sachet/services/zhengfang_jwxt/free_classroom/models/free_classroom_data_response_zf.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_zf_child_pages/free_classroom_result_page_zf.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/widgets/utils_widgets/error_with_retry_widget.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';

class FreeClassroomQueryPageZF extends StatefulWidget {
  const FreeClassroomQueryPageZF({super.key, required this.onFiltering});
  final VoidCallback onFiltering;
  @override
  State<FreeClassroomQueryPageZF> createState() =>
      _FreeClassroomQueryPageZFState();
}

class _FreeClassroomQueryPageZFState extends State<FreeClassroomQueryPageZF> {
  late Future<List<FreeClassroomDataResponseZF>> future;

  bool _showFab = true;

  final ScrollController _scrollController = ScrollController();
  // 更新 FloatingActionButton 的显示状态
  void _updateFABVisibility(bool show) {
    if (_showFab != show) {
      setState(() {
        _showFab = show;
      });
    }
  }

  Future<List<FreeClassroomDataResponseZF>> getFreeClassroomData() async {
    final result = await context
        .read<FreeClassroomPageZFProvider>()
        .getData(cookie: ZhengFangUserProvider.cookie);

    return result;
  }

  void _onRetry() {
    setState(() {
      future = getFreeClassroomData();
    });
  }

  @override
  void initState() {
    super.initState();
    future = getFreeClassroomData();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // 向下滑动, 隐藏 FAB
        _updateFABVisibility(false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // 向上（向前）滑动，显示 FAB
        _updateFABVisibility(true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              if (snapshot.error ==
                  '获取空闲教室数据失败: Http status code = 901, 验证身份信息失败') {
                return LoginExpiredZF(onRetry: _onRetry);
              } else {
                return ErrorWithRetryWidget(
                  text: '${snapshot.error}',
                  onRetry: _onRetry,
                );
              }
            } else {
              return SingleChildScrollView(
                controller: _scrollController,
                child: FreeClassroomResultPageZF(
                  onFiltering: widget.onFiltering,
                  listData: snapshot.data!,
                ),
              );
            }
          }
          // By default, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset(0, 0) : Offset(0, 2),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: FloatingActionButton.extended(
          onPressed: widget.onFiltering,
          label: Text('返回筛选'),
          icon: Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
