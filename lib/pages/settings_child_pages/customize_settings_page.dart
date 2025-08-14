import 'package:flutter/material.dart';
import 'package:sachet/providers/course_card_settings_provider.dart';
import 'package:sachet/widgets/settingspage_widgets/customize_settings_widgets/set_double_value_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/customize_settings_widgets/preview_card.dart';
import 'package:sachet/widgets/settingspage_widgets/customize_settings_widgets/set_course_card_appearance.dart';
import 'package:provider/provider.dart';

class CustomizeSettingsPage extends StatelessWidget {
  const CustomizeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("课表外观"),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.restore_outlined),
        //     tooltip: '重设个性化设置',
        //     onPressed: () {},
        //   )
        // ],
      ),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '课程卡片外观',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  // Icons.format_size_outlined,
                  Icons.text_format_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
          // 卡片高度
          Selector<CourseCardSettingsProvider, double>(
              selector: (_, courseCardSettingsProvider) =>
                  courseCardSettingsProvider.cardHeight,
              builder: (context, cardHeight, __) {
                return ListTile(
                  leading: const Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.height),
                  ),
                  title: const Text('卡片高度'),
                  subtitle: Text(cardHeight.toString()),
                  onTap: () async {
                    double? result = await showDialog(
                        context: context,
                        builder: (context) {
                          return SetDoubleValueDialog(
                            title: '设置课程卡片高度',
                            value: cardHeight,
                          );
                        });
                    if (result != null) {
                      context
                          .read<CourseCardSettingsProvider>()
                          .setCardHeight(result);
                    }
                  },
                );
              }),
          // 卡片圆角大小
          Selector<CourseCardSettingsProvider, double>(
              selector: (_, courseCardSettingsProvider) =>
                  courseCardSettingsProvider.cardBorderRadius,
              builder: (context, cardBorderRadius, __) {
                return ListTile(
                  leading: const Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.rounded_corner_outlined)),
                  title: const Text('卡片圆角'),
                  subtitle: Text(cardBorderRadius.toString()),
                  onTap: () async {
                    double? result = await showDialog(
                        context: context,
                        builder: (context) {
                          return SetDoubleValueDialog(
                            title: '设置课程卡片圆角大小',
                            value: cardBorderRadius,
                          );
                        });
                    if (result != null) {
                      context
                          .read<CourseCardSettingsProvider>()
                          .setCardBorderRadius(result);
                    }
                  },
                );
              }),
          // 卡片间距大小
          Selector<CourseCardSettingsProvider, double>(
              selector: (_, courseCardSettingsProvider) =>
                  courseCardSettingsProvider.cardMargin,
              builder: (context, cardMargin, __) {
                return ListTile(
                  leading: const Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.margin_outlined)),
                  title: const Text('卡片边距'),
                  subtitle: Text(cardMargin.toString()),
                  onTap: () async {
                    double? result = await showDialog(
                        context: context,
                        builder: (context) {
                          return SetDoubleValueDialog(
                            title: '设置课程卡片边距大小',
                            value: cardMargin,
                          );
                        });
                    if (result != null) {
                      context
                          .read<CourseCardSettingsProvider>()
                          .setCardMargin(result);
                    }
                  },
                );
              }),

          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '文本外观',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(
                  // Icons.format_size_outlined,
                  Icons.text_format_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),

          // 课程名称外观调整
          SetCourseCardAppearance(
            icon: Icons.class_outlined,
            category: CourseItemCategory.title,
            // dialogTitle: '课程名称外观调整',
            dialogTitle: '课程名称',
          ),

          SetCourseCardAppearance(
            icon: Icons.room_outlined,
            category: CourseItemCategory.place,
            dialogTitle: '上课地点',
          ),

          SetCourseCardAppearance(
            icon: Icons.school_outlined,
            category: CourseItemCategory.instructor,
            dialogTitle: '授课教师',
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '效果预览',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.preview_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
          // 预览卡片
          PreviewCard(),
        ],
      ),
    );
  }
}
