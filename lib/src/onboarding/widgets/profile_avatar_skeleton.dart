import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

class ProfileAvatarSkeleton extends StatelessWidget {
  const ProfileAvatarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('loading'),
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.black.withOpacity(0.04),
        ),
        const SizedBox(height: 20),
        const SkeletonWidget(height: 40, width: 120),
      ],
    );
  }
}
