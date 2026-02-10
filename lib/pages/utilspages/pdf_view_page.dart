import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
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
      final String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: '保存成绩单文件到...',
        fileName: widget.fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: widget.file.readAsBytesSync(),
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

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
      body: PdfViewer.data(
        widget.file.readAsBytesSync(),
        sourceName: widget.fileName,
      ),
    );
  }
}
