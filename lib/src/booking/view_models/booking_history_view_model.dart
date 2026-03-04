import 'dart:async';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/booking/models/event_history.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';
import 'package:intl/intl.dart';

class BookingHistoryViewModel extends BaseViewModel {
  // Dependencies
  final BookingService _bookingService;
  BookingHistoryViewModel(this._bookingService);

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
  Future<void> fetchBookingHistory() async {
    setScreenLoading(true);
    setError(null);

    final response = await _bookingService.fetchBookingHistory();

    if (response is Success) {
      final stream = response.response as Stream<List<EventHistoryModel>>;

      await _historySubscription?.cancel();
      _historySubscription = stream.listen(
        (eventList) {
          _eventHistory = eventList;
          checkCompletedEvents();
          if (isScreenLoading) {
            setScreenLoading(false);
          } else {
            notifyListeners();
          }
        },
        onError: (error) {
          setError(error.toString());
          if (isScreenLoading) setScreenLoading(false);
        },
      );
    } else if (response is Failure) {
      setError(response.response.toString());
      setScreenLoading(false);
    }
  }

  void checkCompletedEvents() {
    final now = DateTime.now();
    for (var event in _eventHistory) {
      if (event.status == 'active' && event.endTime.isBefore(now)) {
        _bookingService.updateBookingStatus(event.bookingId, 'completed');
      }
    }
    notifyListeners();
  }

  String formatDate(DateTime eventDate) {
    return DateFormat('dd MMM, yyyy').format(eventDate);
  }

  String formatTime(DateTime eventDate) {
    return DateFormat('hh:mm a').format(eventDate);
  }
}
