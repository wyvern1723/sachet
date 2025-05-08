import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sachet/utils/services/path_provider_service.dart';

class ViewCachedDataPage extends StatefulWidget {
  const ViewCachedDataPage({super.key, required this.filePath});
  final String filePath;

  @override
  State<ViewCachedDataPage> createState() => _ViewCachedDataPageState();
}

class _ViewCachedDataPageState extends State<ViewCachedDataPage> {
  var editableTextController = TextEditingController();
  int maxLines = 30;
  String datasetValue = '';
  // 是否进入编辑模式
  bool editMode = false;
  // 是否存在未保存的修改
  bool changed = false;
// 是否被修改
  bool modified = false;

  @override
  void initState() {
    super.initState();
    CachedDataStorage().readDataViaFilePath(widget.filePath).then((value) {
      setState(() {
        datasetValue = value;
        editableTextController = TextEditingController(text: value);
        final numLines = '\n'.allMatches(datasetValue).length;
        setState(() {
          maxLines = numLines + 1;
        });
      });
    });
  }

  @override
  void dispose() {
    editableTextController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('有编辑过的内容未保存，确认退出?'),
            content: Text('是否要丢弃修改'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('不保存退出'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('继续编辑'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: !changed,
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          // Navigator.pop(context);
          return;
        }
        if (changed) {
          _onWillPop().then((value) {
            if (value) {
              Navigator.of(context).pop(modified);
            }
          });
        } else {
          Navigator.of(context).pop(modified);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(changed
              ? '* ${widget.filePath.split(Platform.pathSeparator).last}'
              : widget.filePath.split(Platform.pathSeparator).last),
          actions: editMode == false
              ? [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        editMode = true;
                      });
                    },
                    icon: Icon(Icons.edit),
                  )
                ]
              : [
                  IconButton(
                    onPressed: () {
                      if (changed) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('确定要退出编辑模式?'),
                                  content: Text('有编辑过的内容未保存，确定要退出编辑模式?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          editMode = false;
                                          editableTextController.text =
                                              datasetValue;
                                          changed = false;
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Text('退出'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await CachedDataStorage()
                                            .reWriteDataByFilePath(
                                                editableTextController.text,
                                                widget.filePath);
                                        setState(() {
                                          editMode = false;
                                          datasetValue =
                                              editableTextController.text;
                                          changed = false;
                                          modified = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('保存'),
                                    )
                                  ],
                                ));
                      } else {
                        setState(() {
                          editMode = false;
                          editableTextController.text = datasetValue;
                          changed = false;
                        });
                      }
                    },
                    icon: Icon(Icons.close), // 备选：Icons.edit_off
                  ),
                  IconButton(
                    onPressed: changed
                        ? () async {
                            await CachedDataStorage().reWriteDataByFilePath(
                                editableTextController.text, widget.filePath);
                            setState(() {
                              datasetValue = editableTextController.text;
                              changed = false;
                              modified = true;
                            });
                          }
                        : null,
                    icon: Icon(Icons.save),
                  ),
                ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                // 非懒加载，行数多了性能很差(4000行左右)
                // Column(
                //   children: List.generate(
                //     maxLines,
                //     (index) => Text(
                //       index.toString(),
                //       style: TextStyle(
                //           fontSize: 16,
                //           height: 1.5,
                //           color: Theme.of(context).hintColor),
                //     ),
                //   ),
                // ),

                // 懒加载，但是需要加一个 Sizebox 约束，Width 很难确定。
                // SizedBox(
                //   width: 40,
                //   child: CustomScrollView(
                //     shrinkWrap: true,
                //     physics: NeverScrollableScrollPhysics(),
                //     primary: false,
                //     slivers: [
                //       SliverList(
                //         delegate: SliverChildBuilderDelegate(
                //           (BuildContext context, int index) {
                //             return Text(
                //               index.toString(),
                //              textAlign: TextAlign.end,
                //               style: TextStyle(

                //                   fontSize: 16,
                //                   height: 1.5,
                //                   color: Theme.of(context).hintColor),
                //             );
                //           },
                //           childCount: maxLines,
                //         ),
                //       ),
                //       // Rest of the list
                //     ],
                //   ),
                // ),

                // Expanded(flex: 1, child: SizedBox(width: 6)),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 2000),
                        child: TextField(
                          enabled: editMode,
                          // decoration: InputDecoration(border: InputBorder.none),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: maxLines < 40 ? maxLines + 40 : maxLines,
                          controller: editableTextController,
                          onChanged: (text) => {
                            // 如果编辑文本多一行，左边行数序号新加一行
                            setState(() {
                              maxLines = '\n'
                                      .allMatches(editableTextController.text)
                                      .length +
                                  1;
                              changed =
                                  (editableTextController.text != datasetValue);
                            })
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
