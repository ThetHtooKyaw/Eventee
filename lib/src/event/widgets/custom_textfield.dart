import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SizedBox(
      width: 174,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: t.textTheme.bodyMedium?.copyWith(
              color: AppColor.textPlaceholder,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            onTap: onTap,
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              hintText: hintText,
              suffixIcon: Icon(icon, color: AppColor.primary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                  AppFormat.primaryBorderRadius,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                  AppFormat.primaryBorderRadius,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            style: t.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
