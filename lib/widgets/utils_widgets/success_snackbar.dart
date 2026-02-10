import 'package:flutter/material.dart';

SnackBar successSnackBar(BuildContext context, String message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.done, color: Colors.green),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
  );
}
