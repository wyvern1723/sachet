import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/settings_child_pages/theme_settings_page.dart';
import 'package:sachet/providers/theme_provider.dart';
import 'package:sachet/widgets/utils_widgets/section_card.dart';

class IntroThemeScreen extends StatefulWidget {
  /// 引导页：选择主题模式
  const IntroThemeScreen({super.key});

  @override
  State<IntroThemeScreen> createState() => _IntroThemeScreenState();
}

class _IntroThemeScreenState extends State<IntroThemeScreen> {
  /// 生成预览用的 ThemeData
  ThemeData _buildPreviewTheme({required bool useMaterial3}) {
    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: Theme.of(context).brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Theme.of(context).colorScheme.primary,
        brightness: Theme.of(context).brightness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          pinned: true,
          snap: false,
          floating: false,
          title: Text('选择主题模式'),
        ),
        SliverList.list(children: [
          SizedBox(height: 20),
          SectionCard(
            title: '应用主题',
            childPadding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(
                        value: 0,
                        icon: Icon(Icons.brightness_6_outlined),
                        label: Text('跟随系统'),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('明亮'),
                      ),
                      ButtonSegment<int>(
                        value: 2,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('黑暗'),
                      ),
                    ],
                    selected: <int>{themeProvider.themeMode},
                    onSelectionChanged: (Set<int> newSelection) {
                      context
                          .read<ThemeProvider>()
                          .setThemeMode(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          SectionCard(
            title: '主题颜色',
            child: Column(
              children: [
                // 动态取色开关
                ListTile(
                  leading: Align(
                    widthFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.colorize,
                      color: themeProvider.isUsingDynamicColors
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  title: const Text('动态取色'),
                  subtitle: const Text('从壁纸提取主题色'),
                  trailing: Switch(
                      value: themeProvider.isUsingDynamicColors,
                      onChanged: (value) {
                        context
                            .read<ThemeProvider>()
                            .setIsUsingDynamicColors(value);
                      }),
                ),

                // 如果启用动态取色，隐藏这个供用户自定义主题色的组件
                Offstage(
                  offstage: themeProvider.isUsingDynamicColors,
                  // 可折叠（可展开）选择主题颜色 ListTile
                  child: ExpansionTile(
                    leading: const Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.palette),
                    ),
                    title: const Text('选择主题颜色'),
                    subtitle: Text('0x${colorToHex(themeProvider.themeColor)}'),
                    children: const [
                      SizedBox(height: 10),
                      ChooseThemeColor(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          SectionCard(
            title: 'Material Design',
            childPadding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _buildThemeCard(
                    title: 'Material Design 2',
                    previewTheme: _buildPreviewTheme(useMaterial3: false),
                    isSelected: !themeProvider.isMD3,
                    onTap: () => context.read<ThemeProvider>().setIsMD3(false),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildThemeCard(
                    title: 'Material Design 3',
                    previewTheme: _buildPreviewTheme(useMaterial3: true),
                    isSelected: themeProvider.isMD3,
                    onTap: () => context.read<ThemeProvider>().setIsMD3(true),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 80),
        ]),
      ],
    );
  }

  Widget _buildThemeCard({
    required String title,
    required ThemeData previewTheme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Theme(
          data: previewTheme,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(title, style: previewTheme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: () {}, child: Icon(Icons.search)),
                  Switch(value: true, onChanged: (_) {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
