import 'dart:async';

import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/notification/model/notification.dart';
import 'package:eventee/src/notification/repo/notification_service.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/view_models/base_view_model.dart';

class NotificationViewModel extends BaseViewModel {
  // Dependencies
  final NotificationService _notificationService;
  NotificationViewModel(this._notificationService);

  // Variables
  StreamSubscription? _notificationSubscription;
  List<NotificationModel> _notifications = [];

  // Getters
  List<NotificationModel> get notifications => _notifications;

  // Use Cases
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> requestNotificationPermission() async {
    startScreenLoading();

    final response = await _notificationService.requestNotificationPermission();

    if (response is Failure) {
      stopScreenLoadingWithErrorMessage(response.response.toString());
      return;
    }

    setScreenLoading(false);
  }

  Future<void> fetchAllNotifications() async {
    startScreenLoading();

    final response = await _notificationService.fetchAllEvents();

    if (response is Success) {
      final stream = response.response as Stream<List<NotificationModel>>;
      await _notificationSubscription?.cancel();

      _notificationSubscription = stream.listen(
        (notificationList) {
          _notifications = notificationList;

          if (isScreenLoading) {
            setScreenLoading(false);
          }
        },
        onError: (error) {
          stopScreenLoadingWithErrorMessage(error.toString());
        },
      );
    } else if (response is Failure) {
      stopScreenLoadingWithErrorMessage(response.response.toString());
      return;
    }
  }
}
