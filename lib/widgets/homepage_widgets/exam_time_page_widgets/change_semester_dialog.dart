import 'package:flutter/material.dart';
import 'package:sachet/services/get_jwxt_data/process_data/get_exam_time_semesters.dart';
import 'package:sachet/widgets/utils_widgets/login_expired.dart';

class ChangeSemesterDialog extends StatefulWidget {
  const ChangeSemesterDialog({super.key});

  @override
  State<ChangeSemesterDialog> createState() => _ChangeSemesterDialogState();
}

class _ChangeSemesterDialogState extends State<ChangeSemesterDialog> {
  String selectedSemester = '';
  bool isStoreCacheData = false;

  late Future getDataFuture;

  @override
  void initState() {
    super.initState();
    getDataFuture = getExamTimeSemestersData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('更改学期'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          FutureBuilder(
            future: getDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  if (snapshot.error == '登录失效，请重新登录') {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: LoginExpired(),
                    );
                  } else {
                    return Text('${snapshot.error}');
                  }
                } else {
                  selectedSemester = snapshot.data[0];
                  Map semesters = snapshot.data[1];
                  return Column(
                    children: [
                      DropdownMenu<String>(
                        menuHeight: 400,
                        initialSelection: selectedSemester,
                        requestFocusOnTap: false,
                        label: const Text('学期'),
                        onSelected: (String? semester) {
                          if (semester != null) {
                            selectedSemester = semester;
                          }
                        },
                        dropdownMenuEntries: semesters.entries
                            .map((e) => DropdownMenuEntry<String>(
                                  value: e.value,
                                  label: e.key,
                                ))
                            .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CheckboxMenuButton(
                          value: isStoreCacheData,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                isStoreCacheData = value;
                              });
                            }
                          },
                          child: Text('替换缓存数据'),
                        ),
                      ),
                    ],
                  );
                }
              }
              return const Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在获取学期'),
              ]);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, [selectedSemester, isStoreCacheData]);
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
