import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/admin/model/event_history.dart';
import 'package:eventee/src/booking/models/booking_error.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';
import 'package:flutter/material.dart';

class BookingHistoryViewModel extends ChangeNotifier {
  // Dependencies
  final BookingService _bookingService;
  BookingHistoryViewModel(this._bookingService);

  // Variables
  bool _loading = false;
  BookingError? _bookingError;
  Stream<List<EventHistoryModel>>? _historyStream;

  // Getters
  bool get loading => _loading;
  BookingError? get bookingError => _bookingError;
  Stream<List<EventHistoryModel>>? get historyStream => _historyStream;

  // Setters
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void setBookingError(BookingError bookingError) {
    _bookingError = bookingError;
    notifyListeners();
  }

  void clearBookingError() {
    _bookingError = null;
    notifyListeners();
  }

  // Use Cases
  Future<void> fetchBookingHistory() async {
    setLoading(true);
    clearBookingError();

    final response = await _bookingService.fetchBookingHistory();

    if (response is Success) {
      _historyStream = response.response as Stream<List<EventHistoryModel>>;
    } else if (response is Failure) {
      setBookingError(BookingError(message: response.response.toString()));
    }

    setLoading(false);
  }
}
