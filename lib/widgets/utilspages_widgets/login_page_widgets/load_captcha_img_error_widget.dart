import 'package:flutter/material.dart';

class LoadCaptchaImgErrorWidget extends StatelessWidget {
  /// 加载图片验证码失败的 Widget
  const LoadCaptchaImgErrorWidget({super.key, required this.errorInfo});
  final String errorInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Icon(
            Icons.error_outline_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            errorInfo,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
