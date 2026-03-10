import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final Widget child;
  const MenuCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
        ),
        child: child,
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColor.placeholder.withOpacity(0.4),
        highlightColor: AppColor.placeholder.withOpacity(0.4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: AppFormat.primaryPadding,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: AppColor.white, size: 24),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColor.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
