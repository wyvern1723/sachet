import 'package:flutter/material.dart';

class CapsuleTabItem {
  final Widget icon;
  final String label;

  const CapsuleTabItem({required this.icon, required this.label});
}

class CapsuleTabBar extends StatefulWidget {
  final List<CapsuleTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final TabController? controller;

  const CapsuleTabBar({
    super.key,
    required this.tabs,
    required this.onTabSelected,
    this.selectedIndex = 0,
    this.controller,
  });

  @override
  State<CapsuleTabBar> createState() => _CapsuleTabBarState();
}

class _CapsuleTabBarState extends State<CapsuleTabBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant CapsuleTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final animation = widget.controller?.animation ??
        AlwaysStoppedAnimation(_currentIndex.toDouble());

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      child: LayoutBuilder(builder: (context, constraints) {
        // Calculate tabWidth based on the width available inside the 6.0 padding
        final availableWidth = constraints.maxWidth - 12.0;
        final tabWidth = availableWidth / widget.tabs.length;

        // Threshold for switching to vertical layout (icon above text)
        // Threshold for switching to vertical layout (icon above text)
        // Lowered threshold to keep horizontal layout as much as possible
        final bool isVertical = tabWidth < 64;

        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final animationValue = animation.value;

              return Stack(
                children: [
                  // Sliding Highlight
                  Positioned(
                    left: animationValue * tabWidth,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Tab Items
                  Row(
                    children: List.generate(widget.tabs.length, (index) {
                      final distance = (animationValue - index).abs();

                      // Smoothly transition the label's width and opacity
                      final double labelFactor = Curves.easeInOut
                          .transform((1.0 - distance).clamp(0.0, 1.0));

                      // Color transitions
                      final double colorFactor = Curves.easeInOut
                          .transform((1.0 - distance).clamp(0.0, 1.0));

                      final contentColor = Color.lerp(
                        colorScheme.onSurfaceVariant,
                        colorScheme.primary,
                        colorFactor,
                      )!;

                      final icon = DefaultTextStyle.merge(
                        style: TextStyle(color: contentColor),
                        child: IconTheme.merge(
                          data: IconThemeData(color: contentColor),
                          child: widget.tabs[index].icon,
                        ),
                      );

                      final label = Text(
                        widget.tabs[index].label,
                        style: TextStyle(
                          color: contentColor,
                          fontWeight: FontWeight.w500,
                          fontSize: isVertical ? 12 : 14,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      );

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () {
                              if (widget.controller == null) {
                                setState(() => _currentIndex = index);
                              }
                              widget.onTabSelected(index);
                            },
                            borderRadius: BorderRadius.circular(12),
                            splashColor: contentColor.withOpacity(0.1),
                            highlightColor: contentColor.withOpacity(0.05),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: OverflowBar(
                                  alignment: MainAxisAlignment.center,
                                  overflowAlignment:
                                      OverflowBarAlignment.center,
                                  spacing: 4.0,
                                  overflowSpacing: 2.0,
                                  children: [
                                    icon,
                                    ClipRect(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: labelFactor,
                                        child: Opacity(
                                          opacity: labelFactor,
                                          child: label,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
