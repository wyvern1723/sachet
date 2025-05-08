import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/pages/settings_child_pages/palette_settings_page.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:intl/intl.dart';
import '../settings_child_pages/customize_settings_page.dart';
import '../settings_child_pages/color_settings_page.dart';

class CourseSettingsPage extends StatelessWidget {
  const CourseSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          // Navigator.pop(context);
          return;
        } else {
          Navigator.pushReplacementNamed(context, '/class');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('课表设置'),
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/class');
              },
              icon: Icon(Icons.arrow_back_outlined)),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '日期设置',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              leading: const Align(
                  widthFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.edit_calendar_outlined)),
              title: const Text('学期开始日期'),
              subtitle: Selector<SettingsProvider, String>(
                  selector: (_, settingsProvider) =>
                      SettingsProvider.semesterStartDate,
                  builder: (_, semesterStartDate, __) {
                    return Text(
                      DateFormat('yyyy-MM-dd').format(
                          DateTime.tryParse(semesterStartDate) ??
                              constSemesterStartDate),
                    );
                  }),
              onTap: () => selectSemesterStartDate(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '外观设置',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            // 课表外观
            ListTile(
              leading: const Align(
                widthFactor: 1,
                alignment: Alignment.centerLeft,
                // child: Icon(Icons.colorize_outlined),
                child: Icon(Icons.design_services_outlined),
              ),
              title: const Text('课表外观'),
              subtitle: const Text('定制课程安排卡片外观'),
              trailing: Icon(Icons.arrow_forward_outlined),
              onTap: () {
                Navigator.of(context)
                    .push(slideTransitionPageRoute(CustomizeSettingsPage()));
              },
            ),
            // 配色管理
            ListTile(
              leading: const Align(
                widthFactor: 1,
                alignment: Alignment.centerLeft,
                // child: Icon(Icons.colorize_outlined),
                child: Icon(Icons.format_color_fill_outlined),
              ),
              title: const Text('配色调整'),
              subtitle: const Text('调整课程对应的颜色'),
              trailing: Icon(Icons.arrow_forward_outlined),
              onTap: () {
                Navigator.of(context)
                    .push(slideTransitionPageRoute(ColorSettingsPage()));
              },
            ),
            // 配色管理
            ListTile(
              leading: const Align(
                widthFactor: 1,
                alignment: Alignment.centerLeft,
                // child: Icon(Icons.colorize_outlined),
                child: Icon(Icons.palette_outlined),
              ),
              title: const Text('配色管理'),
              subtitle: const Text('修改、创建配色方案'),
              trailing: Icon(Icons.arrow_forward_outlined),
              onTap: () {
                Navigator.of(context)
                    .push(slideTransitionPageRoute(PaletteSettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
