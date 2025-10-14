import 'package:flutter/material.dart';

class PermissionCheckItem {
  // 权限名称
  final String title;

  /// 当前权限状态 (true = 已授权, false = 未授权)
  final bool value;

  /// 未授权时的错误信息
  final String errorMsg;

  /// 点击时触发的回调
  final VoidCallback onTap;

  PermissionCheckItem({
    required this.title,
    required this.value,
    required this.errorMsg,
    required this.onTap,
  });
}
