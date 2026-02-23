import 'dart:async';

import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/booking/models/event_history.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';

class BookingHistoryViewModel extends BaseViewModel {
  // Dependencies
  final BookingService _bookingService;
  BookingHistoryViewModel(this._bookingService);

  // Variables
  StreamSubscription? _historySubscription;
  List<EventHistoryModel> _eventHistory = [];

  // Getters
  List<EventHistoryModel> get eventHistory => _eventHistory;

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
}
