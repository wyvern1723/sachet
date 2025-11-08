import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.title,
    required this.icon,
    this.page,
    this.onTap,
  });
  final String title;
  final IconData icon;
  final Widget? page;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap ??
            () {
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return page!;
                    },
                  ),
                );
              }
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 0.0),
          child: Column(
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
