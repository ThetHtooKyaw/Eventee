import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            indent: AppFormat.secondaryPadding,
            thickness: 1,
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppFormat.secondaryPadding),
          child: Text(
            'OR',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),

        Expanded(
          child: Divider(
            color: Colors.grey[400],
            endIndent: AppFormat.secondaryPadding,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
