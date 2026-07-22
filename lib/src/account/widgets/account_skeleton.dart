import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

class AccountSkeleton extends StatelessWidget {
  const AccountSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppFormat.primaryPadding),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black.withOpacity(0.04),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonWidget(height: 30, width: 200),
                    const SizedBox(height: 4),

                    SkeletonWidget(height: 20, width: 250),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMenuListItem(),
          _buildMenuListItem(),
          _buildMenuListItem(),
          const SizedBox(height: 20),

          SkeletonWidget(height: 40, width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildMenuListItem() {
    return ListTile(
      leading: SkeletonWidget(height: 24, width: 24),
      title: SkeletonWidget(height: 24, width: 100),
      trailing: SkeletonWidget(height: 24, width: 24),
    );
  }
}
