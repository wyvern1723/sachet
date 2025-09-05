import 'package:flutter/material.dart';
import 'package:sachet/models/page_transitions_type.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/theme_provider.dart';

class PageTransitionsDropdownmenu extends StatelessWidget {
  const PageTransitionsDropdownmenu({super.key});

  @override
  Widget build(BuildContext context) {
    String pageTransition = context.select<ThemeProvider, String>(
        (themeProvider) => themeProvider.pageTransition);
    if (pageTransition == PageTransitionsType.predictiveBack.storageValue) {
      pageTransition = PageTransitionsType.zoom.storageValue;
    }
    return DropdownMenu<String>(
      // width: 168,
      initialSelection: pageTransition,
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
      ),
      onSelected: (String? value) {
        if (value != null) {
          context.read<ThemeProvider>().setPageTransition(value);
        }
      },
      dropdownMenuEntries: PageTransitionsType.values
          .where((e) => e != PageTransitionsType.predictiveBack) // 不显示预测性返回这一项
          .map<DropdownMenuEntry<String>>((PageTransitionsType e) {
        return DropdownMenuEntry<String>(
          value: e.storageValue,
          label: e.label,
        );
      }).toList(),
    );
  }
}
