import 'package:eventee/core/themes/app_color.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String hintText;
  final IconData? icon;
  final VoidCallback? onTap;
  final FormFieldValidator<String> validator;
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.keyboardType,
    required this.hintText,
    this.icon,
    this.onTap,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColor.textPlaceholder,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        TextFormField(
          onTap: onTap,
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: icon != null
                ? Icon(icon, color: AppColor.lightPrimary)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
