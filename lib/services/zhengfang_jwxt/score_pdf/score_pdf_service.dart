import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/utils/transform.dart';

import '../auto_login_retry.dart';
import 'score_pdf_link/fetch_score_pdf_link.dart';
import 'score_pdf_link/parse_score_pdf_link.dart';
import 'score_pdf_types/fetch_score_pdf_types.dart';
import 'score_pdf_types/parse_score_pdf_types.dart';

class ScorePdfService {
  const ScorePdfService();

  /// 正方教务系统打印成绩单，获取可选成绩单格式
  ///
  /// Return:
  ///
  /// e.g.,
  ///
  /// {
  /// "中文主修成绩单（最高考虑加分）": "10530-zw-zgmrgs",
  /// "中文主修成绩单（全程）": "10530-zw-qcmrgs",
  /// "中文主修成绩单（最高不考虑加分）": "10530-zw-zgbjf"
  /// }
  Future<Map> getScorePdfTypes({
    required String cookie,
    required ZhengFangUserProvider? zhengFangUserProvider,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final result = await fetchScorePdfTypesZF(cookie: activeCookie);
        return parseScorePdfTypesFromHtmlZF(result.toString());
      },
    );
  }

  /// 正方教务系统打印成绩单，获取成绩单链接
  ///
  /// Return: "https://jw.xtu.edu.cn/jwglxt/templete/scorePrint/score_202312345678_1769943281937.pdf"
  Future<String> getScorePdfLink({
    required String cookie,
    required ZhengFangUserProvider? zhengFangUserProvider,

    /// 成绩单格式
    ///
    /// e.g.,
    /// "中文主修成绩单（最高考虑加分）": "10530-zw-zgmrgs",
    /// "中文主修成绩单（全程）": "10530-zw-qcmrgs",
    /// "中文主修成绩单（最高不考虑加分）": "10530-zw-zgbjf"
    required String type,
  }) async {
    return withAutoLoginRetry(
      initialCookie: cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      action: (activeCookie) async {
        final result =
            await fetchScorePdfLinkZF(cookie: activeCookie, type: type);
        return parseScorePdfLinkZF(result.toString());
      },
    );
  }

  /// 下载成绩单 pdf
  Future downloadScorePdf({
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
          headers: {
            'Referer': 'https://jw.xtu.edu.cn/jwglxt/',
            'cookie': cookie
          },
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
}
