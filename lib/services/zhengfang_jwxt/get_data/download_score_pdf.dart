import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/utils/transform.dart';

/// 下载成绩单 pdf
Future downloadScorePdfZF({
  required String cookie,
  required String pdfUrl,

  /// 文件临时下载到的应用缓存(临时)目录
  required String tmpfilePath,
  required CancelToken cancelToken,
  required Function(double) onProgress,
}) async {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  try {
    await dio.download(
      pdfUrl,
      tmpfilePath,
      cancelToken: cancelToken,
      options: Options(
        headers: {'Referer': 'https://jw.xtu.edu.cn/jwglxt/', 'cookie': cookie},
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          double percent = received / total;
          onProgress(percent);
        }
      },
    );
  } on DioException catch (e) {
    if (CancelToken.isCancel(e)) {
      if (kDebugMode) {
        print('用户取消了下载');
      }
      throw Exception('取消下载');
    } else {
      String? errorTypeText = dioExceptionTypeToText[e.type];
      if (kDebugMode) {
        print('下载失败: $e');
      }
      throw '下载失败: $errorTypeText';
    }
  }
}
