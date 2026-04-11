import 'package:flutter/material.dart';

enum PageTransitionsType {
  zoom(
    storageValue: 'zoom',
    label: 'Android 风格',
    transitionBuilder: ZoomPageTransitionsBuilder(),
  ),
  cupertino(
    storageValue: 'cupertino',
    label: 'iOS 风格',
    transitionBuilder: CupertinoPageTransitionsBuilder(),
  ),
  predictiveBack(
    storageValue: 'predictiveBack',
    label: 'Android 风格(预测性返回)',
    transitionBuilder: PredictiveBackPageTransitionsBuilder(),
  );

  const PageTransitionsType({
    required this.storageValue,
    required this.label,
    required this.transitionBuilder,
  });

  /// 储存在设置里的值
  final String storageValue;

  /// 展示给用户的描述
  final String label;

  final PageTransitionsBuilder transitionBuilder;

  // 添加一个静态方法，通过 storageValue 获取对应的 PageTransitionsType
  static PageTransitionsType? fromStorageValue(String storageValue) {
    try {
      return PageTransitionsType.values.firstWhere(
        (type) => type.storageValue == storageValue,
      );
    } catch (e) {
      // 如果没有找到匹配的，返回null
      return null;
    }
  }

  // 添加一个静态方法，通过 PageTransitionsTyp 获取对应的 storageValue
  static PageTransitionsType? toStorageValue(
      PageTransitionsBuilder transition) {
    try {
      return PageTransitionsType.values.firstWhere(
        (type) => type.transitionBuilder == transition,
      );
    } catch (e) {
      // 如果没有找到匹配的，返回null
      return null;
    }
  }
}
