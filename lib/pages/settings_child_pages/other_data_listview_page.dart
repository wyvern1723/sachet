import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/pages/settings_child_pages/view_data_page.dart';

class OtherMiscDataListviewPage extends StatefulWidget {
  const OtherMiscDataListviewPage({super.key});

  @override
  State<OtherMiscDataListviewPage> createState() =>
      _OtherMiscDataListviewPageState();
}

class _OtherMiscDataListviewPageState extends State<OtherMiscDataListviewPage> {
  List<FileSystemEntity> filesPathList = [];

  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scaffoldMessenger.hideCurrentSnackBar();
    super.dispose();
  }

  /// 获取数据文件列表并刷新界面
  Future<void> _getFileList() async {
    await CachedDataStorage().lsPrefDirectory().then((value) {
      setState(() {
        filesPathList = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getFileList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("其他数据查看"),
      ),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '存在数据',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.toc,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
          ...List.generate(
            filesPathList.length,
            (index) => ListTile(
              title: Text(path.basename(filesPathList[index].path)),
              subtitle: Text('${filesPathList[index].path}'
                  '\n'
                  '更新时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(File(filesPathList[index].path).lastModifiedSync())}'),
              isThreeLine: true,
              trailing: Align(
                widthFactor: 1,
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(fadeTransitionPageRoute(ViewCachedDataPage(
                            filePath: filesPathList[index].path)))
                        .then((_) => {_ ? setState(() {}) : null});
                  },
                  icon: Icon(Icons.edit_note),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
