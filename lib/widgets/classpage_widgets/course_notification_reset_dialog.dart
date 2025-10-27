import 'package:flutter/material.dart';
import 'package:sachet/pages/settings_child_pages/experimental_settings_page.dart';

class CourseNotificationResetDialog extends StatelessWidget {
  /// 提醒用户课程表已更新，原来的课程通知已取消，需重新开启课程通知的 Dialog
  const CourseNotificationResetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('课程通知已重置'),
      content: SingleChildScrollView(
        child: Text(
          '课程表内容已更新，原有的课程通知已被取消。\n'
          '请重新设置课程通知，以免错过上课提醒。',
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
