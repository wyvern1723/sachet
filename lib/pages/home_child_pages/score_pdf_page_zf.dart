import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/utilspages/pdf_view_page.dart';
import 'package:sachet/providers/score_pdf_page_zf_provider.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/download_score_pdf.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_score_pdf_link.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_score_pdf_types.dart';
import 'package:sachet/widgets/homepage_widgets/score_pdf_page_zf_widgets/downloading_dialog.dart';
import 'package:sachet/widgets/homepage_widgets/score_pdf_page_zf_widgets/score_pdf_types_selector.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';
import 'package:sachet/widgets/utils_widgets/success_snackbar.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/error_info_snackbar.dart';
import 'package:path/path.dart' as path;

class ScorePdfPageZF extends StatelessWidget {
  const ScorePdfPageZF({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScorePdfPageZFProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('成绩单')),
        body: _QueryView(),
      ),
    );
  }
}

class _QueryView extends StatefulWidget {
  const _QueryView({super.key});

  @override
  State<_QueryView> createState() => _QueryViewState();
}

class _QueryViewState extends State<_QueryView> {
  late Future getDataFuture;

  Future _getScorePdfTypesData(
    ZhengFangUserProvider? zhengFangUserProvider,
  ) async {
    final scorePdfTypes = await getScorePdfTypesZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );

    if (!mounted) return;
    context.read<ScorePdfPageZFProvider>().setScorePdfTypes(scorePdfTypes);
  }

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        getDataFuture = _getScorePdfTypesData(zhengFangUserProvider);
      });
    }
  }

  Future _downloadPDF(BuildContext context) async {
    final selectedScorePdfType =
        context.read<ScorePdfPageZFProvider>().selectedScorePdfType;

    if (selectedScorePdfType.isEmpty) {
      context
          .read<ScorePdfPageZFProvider>()
          .changeIsShowDropDownMenuError(true);
      return;
    }

    // 下载进度(0.0-1.0)
    final progressNotifier = ValueNotifier<double>(0.0);
    final CancelToken cancelToken = CancelToken();

    // 显示 正在下载... Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (context, percent, child) {
            return DownloadingDialog(
              percent: percent,
              cancelToken: cancelToken,
            );
          },
        );
      },
    );

    try {
      final selectedScorePdfType =
          context.read<ScorePdfPageZFProvider>().selectedScorePdfType;

      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();

      final pdfUrl = await getScorePdfLinkZF(
        cookie: ZhengFangUserProvider.cookie,
        zhengFangUserProvider: zhengFangUserProvider,
        type: selectedScorePdfType,
      );

      /// 应用缓存(临时)目录
      final tempDir = await getTemporaryDirectory();

      /// 文件名, e.g., "score_202312345678_1769943281937.pdf"
      final String fileName = path.basename(pdfUrl);
      final String tmpfilePath = path.join(tempDir.path, fileName);

      await downloadScorePdfZF(
        cookie: ZhengFangUserProvider.cookie,
        pdfUrl: pdfUrl,
        tmpfilePath: tmpfilePath,
        cancelToken: cancelToken,
        onProgress: (newProgress) => progressNotifier.value = newProgress,
      );

      final file = File(tmpfilePath);
      if (!file.existsSync() || file.lengthSync() < 100) {
        throw Exception('下载文件无效');
      }

      if (defaultTargetPlatform == TargetPlatform.linux) {
        if (!context.mounted) return;

        // 关闭 DownloadingDialog
        Navigator.of(context).pop();

        final String? filePath = await FilePicker.platform.saveFile(
          dialogTitle: '保存成绩单文件到...',
          fileName: fileName,
          type: defaultTargetPlatform == TargetPlatform.linux
              ? FileType.any
              : FileType.custom,
          allowedExtensions:
              defaultTargetPlatform == TargetPlatform.linux ? null : ['pdf'],
          bytes: file.readAsBytesSync(),
        );

        if (!context.mounted) return;

        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            successSnackBar(context, '成功保存到: $filePath'),
          );
        }
      } else {
        if (!context.mounted) return;

        // 关闭 DownloadingDialog
        Navigator.of(context).pop();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewPage(
              tmpfilePath: tmpfilePath,
              fileName: fileName,
              file: file,
            ),
          ),
        );
        return;
      }
    } catch (e) {
      // 只有当不是“用户主动取消”且弹窗还显示时，才去关闭弹窗
      // 如果是用户点击取消按钮，弹窗已经在 onPressed 里关闭了，这里不需要再 pop
      bool isUserCancelled = e.toString().contains('取消下载');

      if (!isUserCancelled && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // 如果不是用户主动取消的，才显示错误提示
      if (!isUserCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          errorInfoSnackBar(context, e.toString()),
        );
      }
    } finally {
      progressNotifier.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    getDataFuture = _getScorePdfTypesData(zhengFangUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: getDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          '获取可选成绩单格式中...',
                          style: TextStyle(color: colorScheme.primary),
                        )
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  if (snapshot.error ==
                      "获取可选成绩单格式失败: Http status code = 901, 验证身份信息失败") {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: LoginExpiredZF(
                          onGoBack: (value) => onGoBack(value),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: ScorePdfTypesSelectorZF(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () => _downloadPDF(context),
                      child: Text('下载'),
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
