import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/utils/utils_funtions.dart';

class CardLinkWidget extends StatelessWidget {
  const CardLinkWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.link,
  });
  final String title;
  final IconData icon;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => openLink(link),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: link));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("链接已复制到剪贴板")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 0.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            children: [
              Icon(icon),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
