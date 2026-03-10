import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/booking/models/booking.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';

class EventDetailsViewModel extends BaseViewModel {
  // Dependencies
  final BookingService _bookingService;
  EventDetailsViewModel(this._bookingService);

  // Variables

  // Getters

  // Use Cases
  Future<void> makePayment({required BookingModel bookedEvent}) async {
    setActionLoading(true);
    setError(null);

    final response = await _bookingService.makePayment(
      bookedEvent: bookedEvent,
    );

    if (response is Success) {
      setSuccess(response.response.toString());
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  int formatPrice(String ticketPrice) {
    return int.parse(ticketPrice);
  }
}
