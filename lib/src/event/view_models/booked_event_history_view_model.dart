import 'dart:async';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/event/model/event_history.dart';
import 'package:eventee/src/event/repo/booked_event_service.dart';
import 'package:intl/intl.dart';

class BookedEventHistoryViewModel extends BaseViewModel {
  // Dependencies
  final BookiedEventService _bookedEventService;
  BookedEventHistoryViewModel(this._bookedEventService) {
    fetchBookingHistory();
  }

  // Variables
  StreamSubscription? _historySubscription;
  List<EventHistoryModel> _eventHistory = [];

  // Getters
  List<EventHistoryModel> get activeEventList {
    final now = DateTime.now();
    return _eventHistory
        .where(
          (e) => e.status.toLowerCase() == 'active' && e.endTime.isAfter(now),
        )
        .toList();
  }

  List<EventHistoryModel> get completedEventList {
    final now = DateTime.now();
    return _eventHistory.where((e) {
      final isExpired = e.endTime.isBefore(now);
      final isActive = e.status.toLowerCase() == 'active';
      final isCompleted = e.status.toLowerCase() == 'completed';

      return isCompleted || (isActive && isExpired);
    }).toList();
  }

  List<EventHistoryModel> get cancelledEventList => _eventHistory
      .where((e) => e.status.toLowerCase() == 'cancelled')
      .toList();

  // Use Cases
  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchBookingHistory() async {
    startScreenLoading();

    final response = await _bookedEventService.fetchBookingHistory();

    if (response is Success) {
      final stream = response.response as Stream<List<EventHistoryModel>>;

      await _historySubscription?.cancel();
      _historySubscription = stream.listen(
        (eventList) {
          _eventHistory = eventList;
          checkCompletedEvents();
          setScreenLoading(false);
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

  Future<void> checkCompletedEvents() async {
    final now = DateTime.now();
    for (var event in _eventHistory) {
      if (event.status.toLowerCase() == 'active' &&
          event.endTime.isBefore(now)) {
        await _bookedEventService.updateBookingStatus(
          event.bookingId,
          'completed',
        );
      }
    }
  }

  String formatDate(DateTime eventDate) {
    return DateFormat('dd MMM, yyyy').format(eventDate);
  }

  String formatTime(DateTime eventDate) {
    return DateFormat('hh:mm a').format(eventDate);
  }
}
