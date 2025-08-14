import 'package:flutter/material.dart';

class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
    required this.routeName,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final Widget page;
  final String routeName;
}
