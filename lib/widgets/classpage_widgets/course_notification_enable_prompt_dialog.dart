import 'package:flutter/material.dart';
import 'package:sachet/pages/settings_child_pages/experimental_settings_page.dart';

class CourseNotificationEnablePromptDialog extends StatelessWidget {
  /// 询问是否要开启课程通知的 Dialog
  const CourseNotificationEnablePromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('课程通知已关闭'),
      content: SingleChildScrollView(
        child: Text(
          '开启课程通知后，您将在上课前收到提醒。\n'
          '是否要开启课程通知？',
          style: TextStyle(fontSize: 16),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.of(context)
              ..pop()
              ..push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return const ExperimentalSettingsPage();
                }),
              );
          },
          child: const Text('设置课程通知'),
        ),
      ],
    );
  }
}
