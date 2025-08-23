import 'package:flutter/material.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;
  final IconData? iconData;

  /// 设置页面的分区标题 Widget
  ///
  /// 用于分隔设置页面的不同功能区域（如"课程卡片外观"、"文本外观"、"效果预览"等），
  const SettingsSectionTitle({super.key, required this.title, this.iconData});

  @override
  Widget build(BuildContext context) {
    if (iconData == null) {
      return Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
      );
    } else {
      return Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            iconData,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ],
      );
    }
  }
}
