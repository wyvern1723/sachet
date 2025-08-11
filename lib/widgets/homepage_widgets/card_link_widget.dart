import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
        onTap: () => launchUrl(Uri.parse(link)),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: link));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("链接已复制到剪贴板")),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 0.0),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              SizedBox(width: 16),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
