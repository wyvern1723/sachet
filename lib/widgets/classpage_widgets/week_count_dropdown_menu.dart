import 'package:flutter/material.dart';
import 'package:sachet/provider/app_global.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/provider/class_page_provider.dart';
import 'package:sachet/widgets/modified_widgets/my_drop_down_menu.dart';
import 'package:provider/provider.dart';

class WeekCountDropdownMenu extends StatefulWidget {
  const WeekCountDropdownMenu({
    super.key,
    required this.pageController,
  });
  final PageController pageController;

  @override
  State<WeekCountDropdownMenu> createState() => _WeekCountDropdownMenuState();
}

class _WeekCountDropdownMenuState extends State<WeekCountDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    int curveDuration = context.select<SettingsProvider, int>(
        (settingsProvider) => settingsProvider.curveDuration);
    String curveType = context.select<SettingsProvider, String>(
        (settingsProvider) => settingsProvider.curveType);
    int currentWeekCount = context.select<ClassPageProvider, int>(
        (classPageModel) => classPageModel.currentWeekCount);
    return MyDropdownMenu<int>(
      width: 90,
      initialSelection: currentWeekCount,
      // trailingIcon: const SizedBox.shrink(),
      selectedTrailingIcon: const SizedBox.shrink(),
      menuHeight: 500,
      textStyle: TextStyle(
          color: Theme.of(context).useMaterial3 &&
                  Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500),
      menuStyle: const MenuStyle(),
      requestFocusOnTap: false,
      enableSearch: false,
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
      onSelected: (int? page) {
        if (page != null) {
          // context.watch<ClassPageModel>().updateCurrentWeekCount(page);
          widget.pageController.animateToPage(
            page - 1,
            duration: Duration(milliseconds: curveDuration),
            curve: curveTypes[curveType] ?? Easing.standard,
          );
        }
      },
      dropdownMenuEntries: pageMenuList.map((int value) {
        return DropdownMenuEntry<int>(value: value, label: '第 $value 周');
      }).toList(),
    );
  }
}

// List<int> pageMenuList = <int>[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
List<int> pageMenuList = List.generate(20, (i) => i + 1);
