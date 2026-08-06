import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/src/account/view_models/account_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountBottonsheet extends StatefulWidget {
  final double height;
  final String title;
  final Future<void> Function()? onTap;
  final Widget child;
  const AccountBottonsheet({
    super.key,
    required this.height,
    required this.title,
    required this.onTap,
    required this.child,
  });

  @override
  State<AccountBottonsheet> createState() => _AccountBottonsheetState();
}

class _AccountBottonsheetState extends State<AccountBottonsheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppFormat.primaryPadding),
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: AppColor.placeholder.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.close, size: 32),
              ),

              // Title
              Text(widget.title, style: theme.textTheme.titleSmall),

              // Save Button
              Selector<AccountDetailViewModel, bool>(
                selector: (_, vm) => vm.isActionLoading,
                builder: (context, isActionLoading, child) {
                  return IconButton(
                    onPressed: widget.onTap,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColor.placeholder.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: isActionLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.check, size: 32),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Contents
          widget.child,
        ],
      ),
    );
  }
}
