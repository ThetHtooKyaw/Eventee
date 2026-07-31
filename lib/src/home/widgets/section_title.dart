import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SectionTitle({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppFormat.primaryPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // Action Button
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  'See all',
                  style: t.textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPlaceholder,
                  ),
                ),
                const SizedBox(width: 2),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColor.textPlaceholder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
