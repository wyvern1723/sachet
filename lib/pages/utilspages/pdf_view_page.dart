import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:sachet/widgets/utils_widgets/success_snackbar.dart';
import 'package:sachet/widgets/utilspages_widgets/login_page_widgets/error_info_snackbar.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({
    super.key,
    required this.tmpfilePath,
    required this.fileName,
    required this.file,
  });

  final String tmpfilePath;
  final String fileName;
  final File file;

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool _isPortrait = true;
  late PdfControllerPinch _pdfControllerPinch;

  void _toggleOrientation() {
    if (_isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    _isPortrait = !_isPortrait;
  }

  Future _savePdf(BuildContext context) async {
    try {
      final bytes = await widget.file.readAsBytes();

      final String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: '保存成绩单文件到...',
        fileName: widget.fileName,
        type: defaultTargetPlatform == TargetPlatform.linux
            ? FileType.any
            : FileType.custom,
        allowedExtensions:
            defaultTargetPlatform == TargetPlatform.linux ? null : ['pdf'],
        bytes: bytes,
      );

      if (!context.mounted) return;

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          successSnackBar(context, '成功保存到: $filePath'),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        errorInfoSnackBar(context, '保存失败: $e'),
      );
    }
  }

  // 删除下载到应用临时目录的 PDF 文件
  Future<void> _deleteTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('临时 PDF 文件已成功清理: ${file.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('清理临时 PDF 文件失败: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pdfControllerPinch = PdfControllerPinch(
      document: PdfDocument.openFile(widget.tmpfilePath),
      initialPage: 1,
    );
  }

  @override
  void dispose() {
    _pdfControllerPinch.dispose();

    // 恢复屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _deleteTempFile(widget.file);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            onPressed: _toggleOrientation,
            icon: Icon(Icons.screen_rotation_alt),
            tooltip: '旋转屏幕',
          ),
          IconButton(
            onPressed: () => _savePdf(context),
            icon: Icon(Icons.save),
            tooltip: '另存为',
          ),
        ],
      ),
      body: PdfViewPinch(
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(child: Text(error.toString())),
        ),
        minScale: 0.99,
        controller: _pdfControllerPinch,
      ),
    );
  }
}
