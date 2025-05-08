import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.page,
  });
  final String title;
  final IconData icon;
  final dynamic page;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return page;
              },
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
          width: double.infinity,
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
