import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/booking/models/booking.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';

class EventDetailsViewModel extends BaseViewModel {
  // Dependencies
  final BookingService _bookingService;
  EventDetailsViewModel(this._bookingService);

  // Use Cases
  Future<bool> makePayment({required BookingModel bookedEvent}) async {
    setActionLoading(true);
    setError(null);
    setSuccess(null);

    final response = await _bookingService.makePayment(
      bookedEvent: bookedEvent,
    );

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setSuccess('Booking successful!');
    setActionLoading(false);
    return true;
  }

  int formatPrice(String ticketPrice) {
    return int.parse(ticketPrice);
  }
}
