import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final EdgeInsetsGeometry? childPadding;
  final List<Widget>? children;
  final CrossAxisAlignment? crossAxisAlignment;
  const SectionCard({
    super.key,
    this.title,
    this.margin,
    this.child,
    this.childPadding,
    this.children,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 8.0),
              child: Text(
                title!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          if (child != null)
            Padding(
              padding: childPadding ?? EdgeInsets.zero,
              child: child!,
            ),
          ...?children,
        ],
      ),
    );
  }
}
