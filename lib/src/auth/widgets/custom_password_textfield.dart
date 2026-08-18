import 'package:eventee/core/themes/app_color.dart';
import 'package:flutter/material.dart';

class CustomPasswordTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?) validator;
  final bool obscureIconState;
  final VoidCallback onObscureIconTap;
  const CustomPasswordTextfield({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    required this.obscureIconState,
    required this.onObscureIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      obscureText: obscureIconState,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          onPressed: onObscureIconTap,
          icon: Icon(
            obscureIconState ? Icons.visibility_off : Icons.visibility,
            color: AppColor.lightPrimary,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
