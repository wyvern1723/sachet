import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/models/exam_time_zf.dart';
import 'package:sachet/utils/transform.dart';

class ExamTimeCardZF extends StatelessWidget {
  /// 考试时间查询页面（正方教务）的每门课程的考试时间信息 Card
  const ExamTimeCardZF({
    super.key,
    required this.examTime,
    required this.isDetailedView,
  });

  final ExamTimeZF examTime;
  final bool isDetailedView;

  @override
  Widget build(BuildContext context) {
    final DateTime? startDateTime = _extractDate(examTime.time).startDateTime;
    final DateTime? endDateTime = _extractDate(examTime.time).endDateTime;
    final bool isFinished = endDateTime?.isBefore(DateTime.now()) ?? false;

    return isDetailedView
        ? _buildDetailedCard(context, isFinished, startDateTime, endDateTime)
        : _buildSimpleCard(context, isFinished, startDateTime, endDateTime);
  }

  Widget _buildDetailedCard(BuildContext context, bool isFinished,
      DateTime? startDateTime, DateTime? endDateTime) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.hardEdge,
      color: isFinished
          ? colorScheme.surfaceContainerHighest
          : colorScheme.secondaryContainer,
      child: Stack(
        children: [
          // 在卡片右上角显示倒计时
          Positioned(
            top: 4,
            right: 12,
            child: _CountDown(
              isFinished: isFinished,
              startDateTime: startDateTime,
              endDateTime: endDateTime,
            ),
          ),
          InkWell(
            onTap: () {},
            onLongPress: () {
              Clipboard.setData(
                ClipboardData(
                    text:
                        "课程名称：${examTime.courseTitle}\n考试时间：${examTime.time}\n考试地点：${examTime.place}"),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("考试信息已复制到剪贴板")),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 课程名称
                  Text(
                    examTime.courseTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isFinished
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  // 时间，例如 "2025-11-25(10:30-12:30) 星期二"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: isFinished
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${examTime.time} ${_getWeekday(startDateTime) ?? ''}',
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1,
                            color: isFinished
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 地点
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: isFinished
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          examTime.place,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 16,
                            color: isFinished
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSecondaryContainer,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '考试名称: ${examTime.examName}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isFinished
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    '场地简称: ${examTime.placeShort}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isFinished
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    '教师信息: ${examTime.instructorInfo}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isFinished
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(BuildContext context, bool isFinished,
      DateTime? startDateTime, DateTime? endDateTime) {
    final theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.hardEdge,
      color: isFinished
          ? colorScheme.surfaceContainerHighest
          : colorScheme.secondaryContainer,
      child: Stack(
        children: [
          // 在卡片右上角显示倒计时
          Positioned(
            top: 4,
            right: 12,
            child: _CountDown(
              isFinished: isFinished,
              startDateTime: startDateTime,
              endDateTime: endDateTime,
            ),
          ),
          InkWell(
            onTap: () {},
            onLongPress: () {
              Clipboard.setData(
                ClipboardData(
                    text:
                        "课程名称：${examTime.courseTitle}\n考试时间：${examTime.time}\n考试地点：${examTime.place}"),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("考试信息已复制到剪贴板")),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 课程名称
                  Text(
                    examTime.courseTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isFinished
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                  if (theme.useMaterial3 == false) SizedBox(height: 4.0),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 4.0,
                    runSpacing: 0.0,
                    children: [
                      // 考试时间
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: isFinished
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${examTime.time} ${_getWeekday(startDateTime) ?? ''}',
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 16,
                              // height: 1,
                              color: isFinished
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                      // 考试地点
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: isFinished
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            examTime.place,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 16,
                              color: isFinished
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSecondaryContainer,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 从考试(开始)时间得到星期几
///
/// e.g. 2025-11-25 10:30:00 => "星期二"
String? _getWeekday(DateTime? startDateTime) {
  if (startDateTime != null) {
    return weekdayToXingQiJi[startDateTime.weekday];
  }
  return null;
}

/// 从字符串中提取第一个日期
({DateTime? startDateTime, DateTime? endDateTime}) _extractDate(
    String dateStr) {
  RegExp datePattern = RegExp(
      r"(\d{4}-\d{2}-\d{2})\s*\(\s*(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})\s*\)");

  Match? match = datePattern.firstMatch(dateStr);
  if (match != null) {
    String datePart = match.group(1)!;
    String startTimePart = match.group(2)!;
    String endTimePart = match.group(3)!;
    DateTime? startDateTime = DateTime.tryParse("$datePart $startTimePart:00");
    DateTime? endDateTime = DateTime.tryParse("$datePart $endTimePart:00");
    return (startDateTime: startDateTime, endDateTime: endDateTime);
  }
  return (startDateTime: null, endDateTime: null);
}

class _CountDown extends StatefulWidget {
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  final bool isFinished;
  const _CountDown({
    required this.startDateTime,
    required this.isFinished,
    required this.endDateTime,
  });

  @override
  State<_CountDown> createState() => __CountDownState();
}

class __CountDownState extends State<_CountDown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 只有当考试未结束且有开始时间时，才有倒计时且需要刷新倒计时
    if (!widget.isFinished && widget.startDateTime != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final startDateTime = widget.startDateTime;
    if (startDateTime == null) {
      return Text("");
    }

    if (widget.isFinished) {
      return Text(
        "已结束",
        style: textTheme.bodyLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant),
      );
    } else {
      final now = DateTime.now();
      // 二次检查：虽然父组件传了 isFinished，但定时器跑的时候可能会过结束时间
      // 这里做个动态判断，能让文字即时变成“已结束”
      if (widget.endDateTime != null && now.isAfter(widget.endDateTime!)) {
        _timer?.cancel();
        return Text(
          "已结束",
          style: textTheme.bodyLarge?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant),
        );
      }

      if (DateUtils.isSameDay(startDateTime, now)) {
        final difference = startDateTime.difference(now);
        final dHours = difference.inHours;

        if (startDateTime.isBefore(now)) {
          return Text(
            "正在考试",
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          );
        }
        if (dHours == 0) {
          final dMinutes = difference.inMinutes;
          return _buildRichText(textTheme, colorScheme, "$dMinutes", " 分钟");
        }
        return _buildRichText(textTheme, colorScheme, "$dHours", " 小时");
      } else {
        final dDays = DateUtils.dateOnly(startDateTime)
            .difference(DateUtils.dateOnly(now))
            .inDays;
        if (dDays == 1) {
          // 明天考试
          final difference = startDateTime.difference(now);
          final dHours = difference.inHours;
          return _buildRichText(textTheme, colorScheme, "$dHours", " 小时");
        } else {
          return _buildRichText(textTheme, colorScheme, "$dDays", " 天");
        }
      }
    }
  }

  Widget _buildRichText(TextTheme textTheme, ColorScheme colorScheme,
      String number, String suffix) {
    return RichText(
      text: TextSpan(
        style: textTheme.bodyLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSecondaryContainer,
        ),
        children: <TextSpan>[
          const TextSpan(text: '还有 '),
          TextSpan(
            text: number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}
