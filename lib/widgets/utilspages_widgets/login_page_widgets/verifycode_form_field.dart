import 'package:flutter/material.dart';

class VerifyCodeFormField extends StatelessWidget {
  const VerifyCodeFormField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autocorrect: false,
      obscureText: false,
      // 设定输入类型为 TextInputType.visiblePassword，使输入法启用数字和英文输入（而不是中文）
      keyboardType: TextInputType.visiblePassword,
      decoration:
          const InputDecoration(labelText: '验证码', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请填入右边的验证码';
        }
        return null;
      },
    );
  }
}
