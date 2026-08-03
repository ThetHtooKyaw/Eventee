import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

class AddressTextfieldsSkeletion extends StatelessWidget {
  const AddressTextfieldsSkeletion({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('loading'),
      children: [
        SkeletonWidget(height: 50, width: double.infinity),
        const SizedBox(height: 20),
        SkeletonWidget(height: 50, width: double.infinity),
        const SizedBox(height: 20),
        SkeletonWidget(height: 50, width: double.infinity),
      ],
    );
  }
}
