import 'package:flutter/material.dart';
import 'package:sachet/provider/settings_provider.dart';
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
      enableSearch: false,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        // border: UnderlineInputBorder(borderSide: BorderSide.none),
        // fillColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      ),
      // label: const Text('StartupPage'),
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
