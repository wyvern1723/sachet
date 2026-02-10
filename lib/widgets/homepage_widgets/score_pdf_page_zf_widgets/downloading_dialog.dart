import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DownloadingDialog extends StatelessWidget {
  const DownloadingDialog({
    super.key,
    required this.percent,
    required this.cancelToken,
  });

  final double percent;
  final CancelToken cancelToken;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('正在下载...'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(percent * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: percent),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {
                // 触发取消
                cancelToken.cancel();
                Navigator.of(context).pop(); // 关闭弹窗
              },
              child: const Text('取消'),
            ),
          ),
        )
      ],
    );
  }
}
