import 'package:flutter/material.dart';

class CompactErrorTile extends StatelessWidget {
  final String errorMsg;

  /// 小的(紧凑的) 显示 warning icon(⚠) + 错误信息的 Tile
  const CompactErrorTile({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 18.0),
          SizedBox(width: 8.0),
          Flexible(
            child: Text(
              errorMsg,
              style: TextStyle(color: Colors.red, fontSize: 13.0),
            ),
          ),
        ],
      ),
    );
  }
}
