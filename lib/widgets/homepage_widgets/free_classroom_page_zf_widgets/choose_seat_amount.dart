import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/rounded_rectangle_container.dart';

class ChooseSeatAmount extends StatefulWidget {
  /// 选择座位数
  const ChooseSeatAmount({super.key});

  @override
  State<ChooseSeatAmount> createState() => _ChooseSeatAmountState();
}

class _ChooseSeatAmountState extends State<ChooseSeatAmount> {
  bool _isRangeSliderMode = true;
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  void _toggleInputMode() {
    setState(() {
      _isRangeSliderMode = !_isRangeSliderMode;
    });
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFilterSeatAmount = context.select<FreeClassroomPageZFProvider, bool>(
        (freeClassroomPageZFProvider) =>
            freeClassroomPageZFProvider.isFilterSeatAmount);
    double currentMinSeatAmount =
        context.select<FreeClassroomPageZFProvider, double>(
            (freeClassroomPageZFProvider) =>
                freeClassroomPageZFProvider.currentMinSeatAmount);
    double? currentMaxSeatAmount =
        context.select<FreeClassroomPageZFProvider, double?>(
            (freeClassroomPageZFProvider) =>
                freeClassroomPageZFProvider.currentMaxSeatAmount);
    _minController.text = currentMinSeatAmount.round().toString();
    _maxController.text = currentMaxSeatAmount == null
        ? "∞"
        : currentMaxSeatAmount.round().toString();
    return RoundedRectangleContainer(
      title: Row(
        children: [
          const Text(
            "座位数",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const Spacer(),
          if (!isFilterSeatAmount)
            SizedBox(
              width: 80,
              child: InputDecorator(
                textAlign: TextAlign.center,
                // textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(),
                child: Center(
                  child: Text(
                    '无限制',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                ),
              ),
            ),
          if (!isFilterSeatAmount) Spacer(),
          if (isFilterSeatAmount)
            TextButton.icon(
              icon: Icon(
                Icons.swap_horiz,
                size: 20,
              ),
              onPressed: _toggleInputMode,
              label: Text(
                '切换输入模式',
                style: TextStyle(fontSize: 12),
              ),
            ),
          TextButton.icon(
            icon: Icon(
              isFilterSeatAmount ? Icons.restart_alt : Icons.filter_list,
              size: 20,
            ),
            onPressed: () {
              context
                  .read<FreeClassroomPageZFProvider>()
                  .toggleIsFilterSeatAmount();
            },
            label: Text(
              isFilterSeatAmount ? '重置' : '筛选',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          //淡入淡出
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          );
        },
        child: isFilterSeatAmount
            ? _buildFilterState(
                context,
                currentMinSeatAmount,
                currentMaxSeatAmount,
              )
            : _buildNotFilterState(),
      ),
    );
  }

  Widget _buildNotFilterState() {
    // return Text('无限制');
    return SizedBox();
  }

  Widget _buildFilterState(
    BuildContext context,
    double currentMinSeatAmount,
    double? currentMaxSeatAmount,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // 淡入淡出
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );

        // 平移
        // return SlideTransition(
        //   position: Tween<Offset>(
        //     begin: Offset(_isRangeSliderMode ? 1.0 : -1.0, 0),
        //     end: Offset.zero,
        //   ).animate(animation),
        //   child: child,
        // );

        // 旋转
        // return RotationTransition(
        //   turns: Tween<double>(begin: 0.02, end: 0).animate(animation),
        //   child: FadeTransition(
        //     opacity: animation,
        //     child: child,
        //   ),
        // );

        // 缩放
        // return ScaleTransition(
        //   scale: animation,
        //   child: child,
        // );

        // 缩放+淡入淡出
        // return ScaleTransition(
        //   scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
        //   child: FadeTransition(
        //     opacity: animation,
        //     child: child,
        //   ),
        // );

        // 淡入淡出 + 轻微上浮
        // return SlideTransition(
        //   position: Tween<Offset>(
        //     begin: const Offset(0, 0.1),
        //     end: Offset.zero,
        //   ).animate(animation),
        //   child: FadeTransition(opacity: animation, child: child),
        // );
      },
      child: _isRangeSliderMode
          ? _buildRangeSlider(
              context,
              currentMinSeatAmount,
              currentMaxSeatAmount,
            )
          : _buildInputField(context),
    );
  }

  Widget _buildRangeSlider(
    BuildContext context,
    double currentMinSeatAmount,
    double? currentMaxSeatAmount,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            // rangeTrackShape:
            //     RectangularRangeSliderTrackShape(),
            // valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            // showValueIndicator: ShowValueIndicator.always,
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: RangeSlider(
            values: RangeValues(
              currentMinSeatAmount,
              currentMaxSeatAmount ?? FreeClassroomPageZFProvider.seatAmountMax,
            ),
            min: FreeClassroomPageZFProvider.seatAmountMin,
            max: max(
              FreeClassroomPageZFProvider.seatAmountMax,
              currentMaxSeatAmount ?? 1,
            ),
            divisions: (FreeClassroomPageZFProvider.seatAmountMax -
                    FreeClassroomPageZFProvider.seatAmountMin)
                .toInt(),
            labels: RangeLabels(
              _minController.text,
              _maxController.text,
            ),
            onChanged: (RangeValues values) {
              context
                  .read<FreeClassroomPageZFProvider>()
                  .updateSeatAmountRangeValues(values);
            },
          ),
        ),
        Text(
          '${_minController.text} 至 ${currentMaxSeatAmount == FreeClassroomPageZFProvider.seatAmountMax ? "∞" : _maxController.text}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Padding(
      // padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 21.0),
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: _minController,
              autocorrect: false,
              obscureText: false,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context
                      .read<FreeClassroomPageZFProvider>()
                      .updateMinSeatAmount(value);
                }
              },
            ),
          ),
          SizedBox(width: 20),
          Text('至'),
          SizedBox(width: 20),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: _maxController,
              autocorrect: false,
              obscureText: false,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: (value) {
                context
                    .read<FreeClassroomPageZFProvider>()
                    .updateMaxSeatAmount(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
