import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/event/model/booking.dart';
import 'package:eventee/src/event/repo/booked_event_service.dart';

class EventDetailsViewModel extends BaseViewModel {
  // Dependencies
  final BookiedEventService _bookedEventService;
  EventDetailsViewModel(this._bookedEventService);

  // Use Cases
  Future<bool> makePayment({required BookingModel bookedEvent}) async {
    startActionLoading();

    final response = await _bookedEventService.makePayment(
      bookedEvent: bookedEvent,
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    stopActionLoadingWithSuccessMessage('Booking successful!');
    return true;
  }

  int formatPrice(String ticketPrice) {
    return int.parse(ticketPrice);
  }
}
