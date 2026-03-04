import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SectionTitle({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppFormat.primaryPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              'See all',
              style: t.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}