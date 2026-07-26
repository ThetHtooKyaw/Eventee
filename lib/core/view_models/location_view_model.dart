import 'package:eventee/core/services/location_service.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';

class LocationViewModel extends BaseViewModel {
  // Dependencies
  final LocationService _locationService;
  final AccountService _accountService;

  LocationViewModel(this._locationService, this._accountService);

  // Use Cases
  Future<bool> requestLocationPermission() async {
    setError(null);

    // Request location permission in the LocationService
    final response = await _locationService.requestLocationPermission();

    if (response is Failure) {
      setError(response.response.toString());
      return false;
    }

    final address = (response as Success).response as String;

    if (address == LocationService.skipToken) {
      return true;
    }

    // Update the user's address in the AccountService
    final accountResponse = await _accountService.updateAddress(
      newAddress: address,
    );

    if (accountResponse is Failure) {
      setError(accountResponse.response.toString());
      return false;
    }

    return true;
  }
}
