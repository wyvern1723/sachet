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

  const CapsuleTabBar({
    super.key,
    required this.tabs,
    required this.onTabSelected,
    this.selectedIndex = 0,
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

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.tabs.length, (index) {
            final isSelected = _currentIndex == index;

            final containerColor = isSelected
                ? colorScheme.secondaryContainer
                : Colors.transparent;
            final contentColor = isSelected
                // ? colorScheme.onSecondaryContainer
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Easing.standard,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (_currentIndex == index) return;
                      setState(() => _currentIndex = index);
                      widget.onTabSelected(index);
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor: contentColor.withOpacity(0.1),
                    highlightColor: contentColor.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Easing.standard,
                          child: OverflowBar(
                            alignment: MainAxisAlignment.center,
                            overflowAlignment: OverflowBarAlignment.center,
                            spacing: 4.0,
                            overflowSpacing: 4.0,
                            children: [
                              widget.tabs[index].icon,
                              if (isSelected)
                                Text(
                                  widget.tabs[index].label,
                                  style: TextStyle(
                                    color: contentColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
