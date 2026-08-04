import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/src/account/view_models/account_detail_view_model.dart';
import 'package:eventee/src/account/widgets/account_bottonsheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalInformationCard extends StatelessWidget {
  final String title;
  final String data;
  final bool isReadOnly;
  final Future<void> Function()? onTap;
  final Widget child;

  const PersonalInformationCard({
    super.key,
    required this.title,
    required this.data,
    this.isReadOnly = false,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Material widget is used to provide the InkWell effect on tap. It allows the ripple effect to be visible when the card is tapped.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: AppColor.placeholder.withOpacity(0.4),
        highlightColor: AppColor.placeholder.withOpacity(0.4),
        onTap: isReadOnly
            ? null
            : () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (sheetContext) {
                  return ChangeNotifierProvider.value(
                    value: context.read<AccountDetailViewModel>(),
                    child: AccountBottonsheet(
                      height: MediaQuery.of(sheetContext).size.height * 0.7,
                      title: title,
                      onTap: onTap,
                      child: child,
                    ),
                  );
                },
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: AppFormat.primaryPadding,
          ),
          child: Row(
            children: [
              Text(
                title,
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  data,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPlaceholder,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              isReadOnly
                  ? const SizedBox.shrink()
                  : Icon(Icons.chevron_right, color: AppColor.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
