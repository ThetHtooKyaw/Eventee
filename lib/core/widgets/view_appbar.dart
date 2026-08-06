import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class ViewAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Widget? actionButton;
  const ViewAppbar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      leadingWidth: 80,
      actionsPadding: const EdgeInsets.only(right: AppFormat.primaryPadding),
      centerTitle: centerTitle,
      // Title
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      // Back Button
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 26),
      ),
      // Action Buttons
      actions: [actionButton ?? const SizedBox.shrink()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
