import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:eventee/src/notification/model/notification.dart';
import 'package:eventee/src/notification/view_models/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late final NotificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<NotificationViewModel>();
    _viewModel.fetchAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: ViewAppbar(title: 'Notifications'),
      body: Selector<NotificationViewModel, bool>(
        selector: (_, vm) => vm.isScreenLoading,
        builder: (context, isScreenLoading, child) {
          if (isScreenLoading) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppFormat.primaryPadding),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppFormat.secondaryPadding),
              itemCount: 6,
              itemBuilder: (context, index) {
                return SkeletonWidget(height: 150, width: double.infinity);
              },
            );
          }

          return child!;
        },
        child: Selector<NotificationViewModel, List<NotificationModel>>(
          selector: (_, vm) => vm.notifications,
          builder: (context, notifications, child) {
            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  'No notifications found!',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppFormat.primaryPadding),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppFormat.secondaryPadding),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return _buildNotificationCard(
                  theme,
                  notification.title,
                  notification.message,
                  notification.status,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    ThemeData theme,
    String title,
    String message,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppFormat.secondaryPadding,
        horizontal: AppFormat.secondaryPadding,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,

            backgroundColor: status == 'success' ? Colors.green : Colors.red,
            child: Icon(
              Icons.notifications,
              size: 28,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
