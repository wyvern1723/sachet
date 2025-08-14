import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/utils_funtions.dart';

class DisclaimerDialog extends StatelessWidget {
  /// 声明 Dialog
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('声明'),
      content: MarkdownBody(
        data: disclaimer,
        onTapLink: (text, href, title) {
          if (href != null) {
            openLink(href);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<SettingsProvider>().setHasReadDisclaimer();
            Navigator.of(context).pop();
          },
          child: Text('我知道了'),
        )
      ],
    );
  }
}
