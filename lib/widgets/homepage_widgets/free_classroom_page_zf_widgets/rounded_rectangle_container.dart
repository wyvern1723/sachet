import 'package:flutter/material.dart';

class RoundedRectangleContainer extends StatelessWidget {
  final Widget title;
  final Widget? child;
  final List<Widget>? children;
  final Axis direction;
  final bool usingWrap;
  const RoundedRectangleContainer({
    super.key,
    required this.title,
    this.child,
    this.children,
    this.direction = Axis.vertical,
    this.usingWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHigh.withAlpha(200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: direction == Axis.vertical
          ? Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: title),
                if (child != null) child!,
                if (children != null) ...children!,
              ],
            )
          : usingWrap
              ? Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    title,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (child != null) child!,
                        if (children != null) ...children!
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Align(alignment: Alignment.centerLeft, child: title),
                    Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (child != null) child!,
                        if (children != null) ...children!
                      ],
                    ),
                    Spacer(),
                  ],
                ),
    );
  }
}
