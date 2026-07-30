import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class CustomIconLabel extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const CustomIconLabel({super.key, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppFormat.secondaryPadding),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(
              AppFormat.secondaryBorderRadius,
            ),
          ),
          child: Icon(icon, color: AppColor.primary, size: 20),
        ),
        const SizedBox(width: 6),

        child,
      ],
    );
  }
}
