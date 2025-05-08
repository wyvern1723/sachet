import 'package:flutter/material.dart';

class DataFromCacheOrHttp extends StatelessWidget {
  const DataFromCacheOrHttp({
    super.key,
    required this.useCache,
    required this.updataTime,
  });
  final bool useCache;
  final String updataTime;

  @override
  Widget build(BuildContext context) {
    return Text(
      useCache ? '使用缓存数据 上次更新: $updataTime' : '使用即时数据 更新时间: $updataTime',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
