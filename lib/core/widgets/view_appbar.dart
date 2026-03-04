import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class ViewAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget actionIcon;
  const ViewAppbar({super.key, required this.actionIcon});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      leadingWidth: 80,
      // Back Button
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 32),
      ),
      actionsPadding: const EdgeInsets.only(right: AppFormat.primaryPadding),
      actions: [actionIcon],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
