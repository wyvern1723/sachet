import 'package:flutter/material.dart';
import 'package:sachet/utils/utils_functions.dart';

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
        onLongPress: () => copyToClipboard(context, link, prefix: '链接'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 6.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                applyTextScaling: true,
              ),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
