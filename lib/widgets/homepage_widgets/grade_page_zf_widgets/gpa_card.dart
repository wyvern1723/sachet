import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sachet/services/zhengfang_jwxt/gpa/models/gpa_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/zhengfang_jwxt.dart';
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

  /// 当前选中的课程属性
  late String _currentCourseType;

  @override
  void initState() {
    super.initState();
    _currentCourseType = widget.courseType;
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _future = _getGPAData(zhengFangUserProvider, _currentCourseType);
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _future = _getGPAData(zhengFangUserProvider, _currentCourseType);
      });
    }
  }

  /// 获取 GPA 数据
  Future _getGPAData(
    ZhengFangUserProvider? zhengFangUserProvider,
    String courseType,
  ) async {
    final result = await ZhengFangJwxt.gpa.getGPA(
      cookie: ZhengFangUserProvider.cookie,
      startSemester: widget.startSemester,
      endSemester: widget.endSemester,
      courseType: courseType,
      zhengFangUserProvider: zhengFangUserProvider,
    );
    return result;
  }

  void _handleCourseTypeChanged(String newType) {
    if (_currentCourseType == newType) return;
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    setState(() {
      _currentCourseType = newType;
      _future = _getGPAData(zhengFangUserProvider, _currentCourseType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '绩点排名数据',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                _buildSegmentedControl(context),
              ],
            ),
            const SizedBox(height: 4),
            FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 106,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '更新中...',
                            style: TextStyle(color: colorScheme.primary),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  if (snapshot.error ==
                      '获取绩点排名数据失败: Http status code = 302, 可能需要重新登录') {
                    return SizedBox(
                      height: 106,
                      child: Center(
                        child: LoginExpiredZF(
                          onGoBack: (value) => onGoBack(value),
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 106,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ),
                  );
                }

                final gpaResponseZF = snapshot.data;
                if (gpaResponseZF == null) {
                  return SizedBox(
                    height: 106,
                    child: Center(
                      child: Text(
                        '数据为空',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  );
                }

                // 加载成功后渲染数据内容
                return _buildCardDataContent(context, gpaResponseZF);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 水平滑动高亮动画分段切换器
  Widget _buildSegmentedControl(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 根据当前选中的课程类型计算水平对齐值
    // -1.0 = 最左边 (全部), 0.0 = 中间 (必修), 1.0 = 最右边 (选修)
    double alignmentX = -1.0;
    if (_currentCourseType == 'bx') {
      alignmentX = 0.0;
    } else if (_currentCourseType == 'xx') {
      alignmentX = 1.0;
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSecondaryContainer.withOpacity(0.06),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(2),
      child: Stack(
        children: [
          // 水平滑动的背景高亮 Pill
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment(alignmentX, 0.0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),

          IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSegmentedItem(context, type: '', label: '全部'),
                _buildSegmentedItem(context, type: 'bx', label: '必修'),
                _buildSegmentedItem(context, type: 'xx', label: '选修'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 单个分段选项
  Widget _buildSegmentedItem(
    BuildContext context, {
    required String type,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _currentCourseType == type;

    return GestureDetector(
      onTap: () => _handleCourseTypeChanged(type),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSecondaryContainer,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  /// 数据内容区域
  Widget _buildCardDataContent(
      BuildContext context, GpaResponseZF gpaResponseZF) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // GPA
        Text(
          'GPA: ${gpaResponseZF.pjxfjd}',
          style: TextStyle(
            fontSize: 18,
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
                fontSize: 14,
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
              size: 14,
              applyTextScaling: true,
            ),
            SizedBox(width: 8),
            Text(
              '班级排名: ${gpaResponseZF.jdbjpm}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),

        // 专业排名
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              color: colorScheme.onSecondaryContainer,
              size: 14,
              applyTextScaling: true,
            ),
            SizedBox(width: 8),
            Text(
              '专业排名: ${gpaResponseZF.jdnjzypm}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
