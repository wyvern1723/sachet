import 'package:flutter/material.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:provider/provider.dart';

enum StartupPageLabel {
  classpage('课程表', '/class'),
  homepage('Home', '/home');

  const StartupPageLabel(this.label, this.routeName);
  final String label;
  final String routeName;
}

class StartupPageDropdownMenu extends StatelessWidget {
  const StartupPageDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String startupPage = context.select<SettingsProvider, String>(
        (settngsProvider) => settngsProvider.startupPage);
    return DropdownMenu<String>(
      width: 120,
      initialSelection: startupPage,
      // enableFilter: true,
      requestFocusOnTap: false,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
          return switch ((
            Theme.of(context).brightness,
            states.contains(WidgetState.disabled)
          )) {
            (Brightness.dark, true) => const Color(0x0DFFFFFF), //  5% white
            (Brightness.dark, false) => const Color(0x1AFFFFFF), // 10% white
            (Brightness.light, true) => const Color(0x05000000), //  2% black
            (Brightness.light, false) => const Color(0x0A000000), //  4% black
          };
        }),
        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      ),
      onSelected: (String? route) {
        if (route != null) {
          context.read<SettingsProvider>().setStartupPage(route);
        }
      },
      dropdownMenuEntries: StartupPageLabel.values
          .map<DropdownMenuEntry<String>>((StartupPageLabel page) {
        return DropdownMenuEntry<String>(
          value: page.routeName,
          label: page.label,
        );
      }).toList(),
    );
  }
}
