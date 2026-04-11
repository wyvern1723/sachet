import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/widgets/modified_widgets/my_drop_down_menu.dart';
import 'package:provider/provider.dart';

class MonthCountDropdownMenu extends StatefulWidget {
  const MonthCountDropdownMenu({super.key});

  @override
  State<MonthCountDropdownMenu> createState() => _MonthCountDropdownMenuState();
}

class _MonthCountDropdownMenuState extends State<MonthCountDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    int curveDuration = context.select<SettingsProvider, int>(
        (settingsProvider) => settingsProvider.curveDuration);
    String curveType = context.select<SettingsProvider, String>(
        (settingsProvider) => settingsProvider.curveType);
    List<MonthData> monthList =
        context.select<ClassPageProvider, List<MonthData>>(
            (classPageModel) => classPageModel.monthList);
    int currentMonth = context.select<ClassPageProvider, int>(
        (classPageModel) => classPageModel.currentMonth);

    return MyDropdownMenu<MonthData>(
      // width: 200,
      initialSelection:
          monthList.firstWhereOrNull((e) => e.month == currentMonth),
      // trailingIcon: const SizedBox.shrink(),
      selectedTrailingIcon: const SizedBox.shrink(),
      menuHeight: 500,
      textStyle: TextStyle(
        color: Theme.of(context).useMaterial3
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
        // OR:
        // color: (!Theme.of(context).useMaterial3 && Theme.of(context).brightness == Brightness.light)
        //     ? Theme.of(context).colorScheme.onPrimary
        //     : Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      menuStyle: const MenuStyle(),
      requestFocusOnTap: false,
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
      onSelected: (MonthData? monthData) {
        if (monthData != null) {
          context.read<ClassPageProvider>().animateToMonth(
                month: monthData.month,
                duration: Duration(milliseconds: curveDuration),
                curve: curveTypes[curveType] ?? Easing.standard,
              );
        }
      },
      dropdownMenuEntries: monthList.map((entry) {
        return DropdownMenuEntry<MonthData>(value: entry, label: entry.label);
      }).toList(),
    );
  }
}
