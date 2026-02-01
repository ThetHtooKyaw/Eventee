import 'package:eventee/core/status/failure.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/booking/models/booking_error.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';
import 'package:flutter/material.dart';

class EventDetailsViewModel extends ChangeNotifier {
  // Dependencies
  final BookingService _bookingService;
  EventDetailsViewModel(this._bookingService);

  // Variables
  bool _loading = false;
  BookingError? _bookingError;

  // Getters
  bool get loading => _loading;
  BookingError? get bookingError => _bookingError;

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
  Future<void> makePayment({
    required EventModel event,
    required double amount,
    required int quantity,
  }) async {
    setLoading(true);
    clearBookingError();

    final response = await _bookingService.makePayment(
      event: event,
      amount: amount,
      quantity: quantity,
    );

    if (response is Failure) {
      setBookingError(BookingError(message: response.response.toString()));
    }

    setLoading(false);
  }
}
