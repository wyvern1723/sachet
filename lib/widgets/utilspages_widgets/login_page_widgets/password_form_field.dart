import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({super.key, required this.controller});

  final TextEditingController controller;
  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool isObscure = true; // 控制密码是否可见（小眼睛）
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autocorrect: false,
      obscureText: isObscure,
      // 设定输入类型为 TextInputType.visiblePassword，使输入法启用数字和英文输入（而不是中文）
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        filled: false,
        labelText: '密码',
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
          icon: Icon(
            (isObscure == false) ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请填入您的密码';
        }
        return null;
      },
    );
  }
}
