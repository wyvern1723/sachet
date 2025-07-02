import 'package:flutter/material.dart';
import 'package:sachet/provider/app_global.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class NavTypeDropdownmenu extends StatelessWidget {
  const NavTypeDropdownmenu({super.key, required this.onChangeNavType});
  final Function onChangeNavType;
  @override
  Widget build(BuildContext context) {
    String navigationType = context.select<SettingsProvider, String>(
        (settngsProvider) => SettingsProvider.navigationType);
    return DropdownMenu<String>(
      // width: 152,
      initialSelection: navigationType,
      requestFocusOnTap: false,
      enableSearch: false,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      ),
      onSelected: (String? type) {
        if (type != null) {
          context.read<SettingsProvider>().setNavigationType(type);
          onChangeNavType(type);
        }
      },
      dropdownMenuEntries:
          NavType.values.map<DropdownMenuEntry<String>>((NavType e) {
        return DropdownMenuEntry<String>(
          value: e.type,
          label: e.label,
        );
      }).toList(),
    );
  }
}
