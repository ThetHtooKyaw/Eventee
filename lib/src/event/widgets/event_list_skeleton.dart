import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

class EventListSkeleton extends StatelessWidget {
  final double cardWidth;
  const EventListSkeleton({super.key, this.cardWidth = 340});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppFormat.secondaryPadding),
      width: cardWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        border: Border.all(color: AppColor.placeholder, width: 0.5),
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonWidget(height: 180, width: cardWidth),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonWidget(height: 20, width: 100),
              SkeletonWidget(height: 20, width: 100),
            ],
          ),
        ],
      ),
    );
  }
}
