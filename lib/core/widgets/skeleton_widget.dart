import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class SkeletonWidget extends StatelessWidget {
  final double? height;
  final double? width;
  const SkeletonWidget({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
      ),
    );
  }
}